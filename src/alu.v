module alu (
    // IN
    input wire clk,
    input wire [3:0] alu_op,
    input wire [31:0] src1,
    input wire [31:0] src2,
    // OUT
    output reg [31:0] alu_result,
    output wire zero
);

  always @(posedge clk) begin
    case (alu_op)
      `ALU_ADD:  alu_result = src1 + src2;
      `ALU_SUB:  alu_result = src1 - src2;
      `ALU_SLL:  alu_result = src1 << src2[4:0];
      `ALU_SLT:  alu_result = {31'b0, $signed(src1) < $signed(src2)};
      `ALU_SLTU: alu_result = {31'b0, src1 < src2};
      `ALU_XOR:  alu_result = src1 ^ src2;
      `ALU_SRL:  alu_result = src1 >> src2[4:0];
      `ALU_SRA:  alu_result = $signed(src1) >>> src2[4:0];
      `ALU_OR:   alu_result = src1 | src2;
      `ALU_AND:  alu_result = src1 & src2;
    endcase
  end

  assign zero = &alu_result;

endmodule
