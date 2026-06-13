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

    always @(posedge clk) begin
        if (reset) begin
            for (integer i=0;i<32;i++) begin
                all_register[i] <= 0;
            end
        end
        else begin
            rs1 <= all_register[rs1_addr];
            rs2 <= all_register[rs2_addr];
            if (write_enable) begin
                all_register[rd_addr] <= rd;
            end
        end
    end

endmodule