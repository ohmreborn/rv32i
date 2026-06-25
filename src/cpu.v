module cpu (
    input  wire       clk,
    input  wire       reset,
    output reg        mem_valid,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    output reg [ 3:0] mem_wstrb,
    input  wire [31:0] mem_rdata,
    input  wire        mem_ready
);

    reg [2:0] state;
    reg [31:0] pc;
    reg [31:0] machine_code;
    always @(posedge clk) begin
        if (reset) begin
            mem_addr <= 0;
            mem_valid <= 1'b0;
            state <= `FETCH;
        end
        else begin
            case (state)
                `FETCH: begin
                    pc <= mem_addr;
                    if (mem_ready) begin
                        machine_code <= mem_rdata;
                        mem_valid <= 1'b0;
                        state <= `DECODE;
                    end
                    else begin
                        mem_valid <= 1'b1;
                        mem_wstrb <= 4'b0000;
                        state <= `FETCH;
                    end
                end
                `DECODE: begin
                    // read rs1, rs2
                    state <= `EXEC;
                end
                `EXEC: begin
                    case (load_or_store)
                        `NOT_LOAD_STORE: begin
                            state <= `FETCH;
                            case (register_write_from)
                                `ALU_OUT: rd <= alu_result;
                                `PC_PLUS_4: rd <= pc+4;
                            endcase
                            if (is_jump || (is_branch && branch)) begin
                                mem_addr <= alu_result;
                            end
                            else begin
                                mem_addr <= pc + 4;
                            end
                        end
                        `STORE_MEMORY_ADDRESS: begin
                            state <= `DATAMEM;
                            mem_valid <= 1'b1;
                            mem_addr <= alu_result;
                            mem_wdata <= rs2;
                            // mem_wstrb <= 4'b0000;
                            case (mem_address_mode)
                             `F3_SB: begin
                                case (alu_result[1:0])
                                    2'b00: mem_wstrb <= 4'b0001;
                                    2'b01: mem_wstrb <= 4'b0010;
                                    2'b10: mem_wstrb <= 4'b0100;
                                    2'b11: mem_wstrb <= 4'b1000;
                                endcase
                             end
                             `F3_SH: begin
                                case (alu_result[1:0])
                                    2'b00: mem_wstrb <= 4'b0011;
                                    2'b10: mem_wstrb <= 4'b1100;
                                endcase
                             end
                             `F3_SW: begin
                                mem_wstrb <= 4'b1111;
                             end
                            endcase
                        end
                        `LOAD_MEMORY_ADDRESS: begin
                            state <= `DATAMEM;
                            mem_valid <= 1'b1;
                            mem_addr <= alu_result;
                            mem_wstrb <= 4'b0000;
                        end
                    endcase

                end
                `DATAMEM: begin
                    if (mem_ready) begin
                        state <= `FETCH;
                        mem_valid <= 1'b0;
                        mem_addr <= pc + 4;
                        if (load_or_store == `LOAD_MEMORY_ADDRESS) begin
                            case (mem_address_mode)
                                `F3_LB: begin
                                    case (alu_result[1:0])
                                        2'b00: rd <= {{24{mem_rdata[7]}}, mem_rdata[7:0]};
                                        2'b01: rd <= {{24{mem_rdata[15]}}, mem_rdata[15:8]};
                                        2'b10: rd <= {{24{mem_rdata[23]}}, mem_rdata[23:16]};
                                        2'b11: rd <= {{24{mem_rdata[31]}}, mem_rdata[31:24]};
                                    endcase
                                end
                                `F3_LH: begin
                                    case (alu_result[1:0])
                                        2'b00: rd <= {{16{mem_rdata[15]}}, mem_rdata[15:0]};
                                        2'b10: rd <= {{16{mem_rdata[31]}}, mem_rdata[31:16]};
                                    endcase
                                end
                                `F3_LW: rd <= mem_rdata;
                                `F3_LBU: begin
                                    case (alu_result[1:0])
                                        2'b00: rd <= {{24'b0}, mem_rdata[7:0]};
                                        2'b01: rd <= {{24'b0}, mem_rdata[15:8]};
                                        2'b10: rd <= {{24'b0}, mem_rdata[23:16]};
                                        2'b11: rd <= {{24'b0}, mem_rdata[31:24]};
                                    endcase
                                end
                                `F3_LHU: begin
                                    case (alu_result[1:0])
                                        2'b00: rd <= {{16'b0}, mem_rdata[15:0]};
                                        2'b10: rd <= {{16'b0}, mem_rdata[31:16]};
                                    endcase
                                end
                            endcase
                        end
                    end
                    else begin
                        state <= `DATAMEM;
                    end
                end
            endcase
        end
    end

    wire [31:0] immediate;
 
    wire [6:0] opcode;
    wire [4:0] r1_address;
    wire [4:0] r2_address;
    wire [4:0] rd_address;
    wire [5:0] alu_control;
 
    wire [2:0] mem_address_mode;
    wire [1:0] load_or_store;

    wire register_write_from;
    wire write_reg_enable;

    wire branch_mode;
    wire is_branch;
    wire is_jump;
 
    control_unit control(
        .machine_code(machine_code),
 
        .immediate(immediate),
        .opcode(opcode),
        .r1_address(r1_address),
        .r2_address(r2_address),
        .rd_address(rd_address),
        .alu_control(alu_control),

        .mem_address_mode(mem_address_mode),
        .load_or_store(load_or_store),

        .register_write_from(register_write_from),
        .write_reg_enable(write_reg_enable),

        .branch_mode(branch_mode),
        .is_branch(is_branch),
        .is_jump(is_jump)
    );

    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [31:0] rd;
    register REG(
        .clk(clk),
        .reset(reset),
        .rd_addr(rd_address),
        .rs1_addr(r1_address),
        .rs2_addr(r2_address),
        .rd(rd),
        .write_enable(write_reg_enable),
        .rs1(rs1),
        .rs2(rs2)
    );


    wire [3:0] alu_op = alu_control[5:2];
    wire [31:0] src1 = alu_control[1] ? rs1: pc;
    wire [31:0] src2 = alu_control[0] ? rs2: immediate;
    wire [31:0] alu_result;
    wire branch;
    alu ALU(
        // IN
        .alu_op(alu_op),
        .src1(src1),
        .src2(src2),
        .branch_mode(branch_mode),
        // OUT
        .alu_result(alu_result),
        .branch(branch)
    );

endmodule
