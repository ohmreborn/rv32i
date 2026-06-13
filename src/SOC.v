module SOC(
    input wire clk,
    input wire reset,
    output reg [4:0] LED
); 
 

    reg        mem_valid;
    reg [31:0] mem_addr;
    reg [31:0] mem_wdata;
    reg [ 3:0] mem_wstrb;  // 0000 = read, else = write
    reg  [31:0] mem_rdata;
    wire         mem_ready;

    reg [1:0] state;
    always @(posedge clk) begin
        if (reset) begin
            mem_addr <= 0;
            mem_valid <= 1'b0;
            state <= `FETCH;
        end
        else begin
            case (state)
                `FETCH: begin
                    mem_valid <= 1'b1;
                    mem_wstrb <= 4'b0000;
                    state <= `WAIT_FETCH;
                end
                `WAIT_FETCH: begin
                    if (mem_ready) begin
                        mem_valid <= 1'b0;
                        state <= `DECODE;
                    end
                    else begin
                        state <= `WAIT_FETCH;
                    end
                end
                `DECODE: begin
                    LED <= mem_rdata[4:0];
                    mem_addr <= mem_addr + 4;
                    state <= `FETCH;
                end
            endcase
        end
    end
 
    memory #(
        .MemInit("../../firmware/build/opcode.hex"),
        .MEMSIZE(512)
    ) mem(
        .clk(clk),
        .reset(reset),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready)

    );
 
    wire [31:0] immediate;
 
    wire [6:0] opcode;
    wire [4:0] r1_address;
    wire [4:0] r2_address;
    wire [4:0] rd_address;
    wire [5:0] alu_control;   // FIX: was "reg", must be "wire" (driven by control_unit output)
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
 
 
endmodule