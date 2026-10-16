module register(
    input wire clk, 
    input wire reset,
    input wire [4:0] rd_addr,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [31:0] rd,
    input wire write_enable,

    output reg [31:0] rs1,
    output reg [31:0] rs2
);
    reg [31:0] general_register[0:31];
    wire [31:0] x0 = general_register[0];
    wire [31:0] x1 = general_register[1];
    wire [31:0] x2 = general_register[2];
    wire [31:0] x3 = general_register[3];
    wire [31:0] x4 = general_register[4];
    wire [31:0] x5 = general_register[5];
    wire [31:0] x6 = general_register[6];
    wire [31:0] x7 = general_register[7];
    wire [31:0] x8 = general_register[8];
    wire [31:0] x9 = general_register[9];
    wire [31:0] x10 = general_register[10];
    wire [31:0] x11 = general_register[11];
    wire [31:0] x12 = general_register[12];
    wire [31:0] x13 = general_register[13];
    wire [31:0] x16 = general_register[16];
    wire [31:0] x17 = general_register[17];
    wire [31:0] x18 = general_register[18];
    wire [31:0] x19 = general_register[19];
    wire [31:0] x20 = general_register[20];
    wire [31:0] x21 = general_register[21];
    wire [31:0] x22 = general_register[22];
    wire [31:0] x23 = general_register[23];
    wire [31:0] x24 = general_register[24];
    wire [31:0] x25 = general_register[25];
    wire [31:0] x26 = general_register[26];
    wire [31:0] x27 = general_register[27];
    wire [31:0] x28 = general_register[28];
    wire [31:0] x29 = general_register[29];
    wire [31:0] x30 = general_register[30];
    wire [31:0] x31 = general_register[31];

    always @(posedge clk) begin
        if (reset) begin
            for (integer i=0;i<32;i++) begin
                general_register[i] <= 0;
            end
        end
        else begin
            rs1 <= general_register[rs1_addr];
            rs2 <= general_register[rs2_addr];
            if (write_enable && rd_addr != 5'b0) begin
                general_register[rd_addr] <= rd;
            end
        end
    end

endmodule
