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
    always @(posedge clk) begin
        if (reset) begin
            mem_addr <= 0;
            mem_valid <= 1'b0;
            state <= `FETCH;
        end
        else begin
            case (state)
                `FETCH: begin
                    if (mem_ready) begin
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
                    pc <= mem_addr;
                    state <= `EXEC;
                end
                `EXEC: begin
                    alu_op <= alu_control[5:2];
                    src1 <= alu_control[1] ? rs1: pc;
                    src2 <= alu_control[0] ? rs2: immediate;

                    state <= `WRITE_BACK;
                end
                `WRITE_BACK: begin
                    case (register_write_from)
                        `ALU_OUT: rd <= alu_result;
                        // `DATA_MEMORY: rd <= ;
                        `PC_PLUS_4: rd <= pc+4;
                    endcase
                    mem_addr <= pc + 4;
                    state <= `FETCH;
                end
                // datamem
            endcase
        end
    end

    wire [31:0] immediate;
 
    wire [6:0] opcode;
    wire [4:0] r1_address;
    wire [4:0] r2_address;
    wire [4:0] rd_address;
    wire [5:0] alu_control;
    wire [1:0] alu_out_goto;
    wire [1:0] register_write_from;
 
    reg [2:0] mem_address_mode;
    wire write_mem_enable;
    wire write_reg_enable;
    wire set_pc;
 
    control_unit control(
        .clk(clk),
        .machine_code(mem_rdata),
 
        .immediate(immediate),
        .opcode(opcode),
        .r1_address(r1_address),
        .r2_address(r2_address),
        .rd_address(rd_address),
        .alu_control(alu_control),
        .alu_out_goto(alu_out_goto),
        .register_write_from(register_write_from),

        .mem_address_mode(mem_address_mode),
        .write_mem_enable(write_mem_enable),
        .write_reg_enable(write_reg_enable),
        .set_pc(set_pc)
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


    reg [3:0] alu_op;
    reg [31:0] src1;
    reg [31:0] src2;
    reg [31:0] alu_result;
    reg zero;
    alu ALU(
        // IN
        .clk(clk),
        .alu_op(alu_op),
        .src1(src1),
        .src2(src2),
        // OUT
        .alu_result(alu_result),
        .zero(zero)
    );


endmodule
