module SOC(
    input wire clk,
    input wire reset,
    output wire [4:0] LED
); 
 
    reg [31:0] read_address;
    reg [31:0] read_data;
    wire read_bussy;
 
    wire [31:0] write_address;
    wire [31:0] write_data;
    wire write_enable;
    reg write_bussy;

    always @(posedge clk) begin
        if (reset) begin
            read_address <= 0;
        end
        else begin
            if (!read_bussy) begin
                read_address <= read_address + 4;
            end
        end
    end
 
    memory #(
        .MemInit("../../firmware/build/opcode.hex"),
        .MEMSIZE(64)
    ) mem(
        .clk(clk),
        .reset(reset),
        // read memory
        .read_address(read_address),
        .read_data(read_data),
        .read_bussy(read_bussy),
        // write memory
        .write_address(write_address),
        .write_data(write_data),
        .write_enable(write_enable),
        .write_bussy(write_bussy)
    );
 
    assign LED = read_data[4:0];
 
    wire [31:0] immediate;
 
    wire [6:0] opcode;
    wire [4:0] r1_address;
    wire [4:0] r2_address;
    wire [4:0] rd_address;
    wire [5:0] alu_control;   // FIX: was "reg", must be "wire" (driven by control_unit output)
    wire [1:0] alu_out_goto;
    wire [1:0] register_write_from;
 
    wire write_mem_enable;
    wire write_reg_enable;
    wire set_pc;
 
    control_unit control(
        .clk(clk),
        .machine_code(read_data),
 
        .immediate(immediate),
        .opcode(opcode),
        .r1_address(r1_address),
        .r2_address(r2_address),
        .rd_address(rd_address),
        .alu_control(alu_control),
        .alu_out_goto(alu_out_goto),
        .register_write_from(register_write_from),

        .write_mem_enable(write_mem_enable),
        .write_reg_enable(write_reg_enable),
        .set_pc(set_pc)
    );
 
 
endmodule