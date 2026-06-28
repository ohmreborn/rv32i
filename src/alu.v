module alu (
    // IN
    input wire [3:0] alu_op,
    input wire [31:0] src1,
    input wire [31:0] src2,
    input wire branch_mode,
    // OUT
    output reg [31:0] alu_result,
    output wire branch 
);

  always @(*) begin
    case (alu_op)
      `ALU_ADD:  alu_result = src1 + src2;
      `ALU_SUB:  begin
          alu_result = src1 - src2;
      end
      `ALU_SLL:  alu_result = src1 << src2[4:0];
      `ALU_SLT:  begin
          alu_result = {31'b0, $signed(src1) < $signed(src2)};
      end
      `ALU_SLTU: begin
          alu_result = {31'b0, src1 < src2};
      end
      `ALU_XOR:  alu_result = src1 ^ src2;
      `ALU_SRL:  alu_result = src1 >> src2[4:0];
      `ALU_SRA:  alu_result = $signed(src1) >>> src2[4:0];
      `ALU_OR:   alu_result = src1 | src2;
      `ALU_AND:  alu_result = src1 & src2;
      default: alu_result = 32'b0;
    endcase
  end

assign branch = branch_mode & (alu_result == 32'b0);

endmodule
