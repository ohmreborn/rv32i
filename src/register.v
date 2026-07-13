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
    reg [31:0] all_register[0:31];

    reg [31:0] x0;
    reg [31:0] x1;
    reg [31:0] x2;
    reg [31:0] x3;
    reg [31:0] x4;
    reg [31:0] x5;
    reg [31:0] x6;
    reg [31:0] x7;
    reg [31:0] x8;
    reg [31:0] x9;
    reg [31:0] x10;
    reg [31:0] x11;
    reg [31:0] x12;
    reg [31:0] x13;
    reg [31:0] x14;
    reg [31:0] x15;
    reg [31:0] x16;
    reg [31:0] x17;
    reg [31:0] x18;
    reg [31:0] x19;
    reg [31:0] x20;
    reg [31:0] x21;
    reg [31:0] x22;
    reg [31:0] x23;
    reg [31:0] x24;
    reg [31:0] x25;
    reg [31:0] x26;
    reg [31:0] x27;
    reg [31:0] x28;
    reg [31:0] x29;
    reg [31:0] x30;
    reg [31:0] x31;

    assign x0 = all_register[0];
    assign x1 = all_register[1];
    assign x2 = all_register[2];
    assign x3 = all_register[3];
    assign x4 = all_register[4];
    assign x5 = all_register[5];
    assign x6 = all_register[6];
    assign x7 = all_register[7];
    assign x8 = all_register[8];
    assign x9 = all_register[9];
    assign x10 = all_register[10];
    assign x11 = all_register[11];
    assign x12 = all_register[12];
    assign x13 = all_register[13];
    assign x14 = all_register[14];
    assign x15 = all_register[15];
    assign x16 = all_register[16];
    assign x17 = all_register[17];
    assign x18 = all_register[18];
    assign x19 = all_register[19];
    assign x20 = all_register[20];
    assign x21 = all_register[21];
    assign x22 = all_register[22];
    assign x23 = all_register[23];
    assign x24 = all_register[24];
    assign x25 = all_register[25];
    assign x26 = all_register[26];
    assign x27 = all_register[27];
    assign x28 = all_register[28];
    assign x29 = all_register[29];
    assign x30 = all_register[30];
    assign x31 = all_register[31];

    always @(posedge clk) begin
        if (reset) begin
            for (integer i=0;i<32;i++) begin
                all_register[i] <= 0;
            end
        end
        else begin
            rs1 <= all_register[rs1_addr];
            rs2 <= all_register[rs2_addr];
            if (write_enable && rd_addr != 5'b0) begin
                all_register[rd_addr] <= rd;
            end
        end
    end

endmodule