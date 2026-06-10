`include "decode.v"

module control_unit (
    input wire [31:0] machine_code,

    output wire [ 5:0] alu_control,
    output wire [31:0] immdiate,

    output wire [6:0] opcode,
    output wire [4:0] r1_address,
    output wire [4:0] r2_address,
    output wire [4:0] rd_address,
    output wire [1:0] alu_out_goto,
    output wire [1:0] register_write_from,

    output wire write_mem_enable,
    output wire write_reg_enable,
    output wire set_pc
);

  wire [2:0] func3;
  wire [6:0] func7;
  assign opcode = machine_code[6:0];
  assign func3 = machine_code[14:12];
  assign func7 = machine_code[31:25];
  assign r1_address = machine_code[19:15];
  assign r2_address = machine_code[24:20];
  assign rd_address = machine_code[11:7];
  always_comb begin
    case (opcode)
      OPCODE_IMM_ALU: begin
        alu_control = {{func3, func7[1]}, R1_IMM};
        alu_out_goto = REGISTER;
        register_write_from = ALU_OUT;
        write_mem_enable = 1'b0;
        write_reg_enable = 1'b1;
        set_pc = 1'b0;
        case (func3)
          F3_ADDI, F3_SLTI, F3_SLTIU, F3_XORI, F3_ORI, F3_ANDI: begin
            immediate = {{20{raw_src[24]}}, raw_src[24:13]};
          end
          F3_SRLI_SRAI, F3_SLLI: immdiate = {27'b0, raw_src[24:20]};
          default: immdiate = 'x;
        endcase
      end

      OPCODE_AUIPC: begin
        alu_control = {{ALU_ADD}, PC_IMM};
        alu_out_goto = REGISTER;
        register_write_from = ALU_OUT;
        write_mem_enable = 1'b0;
        write_reg_enable = 1'b1;
        set_pc = 1'b0;
        immediate = {raw_src[24:5], 12'b0};
      end

      OPCODE_LUI: begin
        alu_control = {{func3, func7[1]}, ALU_R0_IMM};
        alu_out_goto = REGISTER;
        register_write_from = ALU_OUT;
        write_mem_enable = 1'b0;
        write_reg_enable = 1'b1;
        set_pc = 1'b0;
        immediate = {raw_src[24:5], 12'b0};
      end

      OPCODE_R_R_INT: begin
        alu_control = {{func3, func7[1]}, R1_R2};
        alu_out_goto = REGISTER;
        register_write_from = ALU_OUT;
        write_mem_enable = 1'b0;
        write_reg_enable = 1'b1;
        set_pc = 1'b0;
        immediate = 'x;  // not care
      end

      OPCODE_STORE: begin
        alu_control = {ALU_ADD, R1_IMM};
        alu_out_goto = WRITE_MEMORY_ADDRESS;
        register_write_from = NOT_WRITE;
        write_mem_enable = 1'b1;
        write_reg_enable = 1'b0;
        set_pc = 1'b0;
        immediate = {{20{raw_src[24]}}, raw_src[24:18], raw_src[4:0]};
      end

      OPCODE_LOAD: begin
        alu_control = {ALU_ADD, R1_IMM};
        alu_out_goto = READ_MEMORY_ADDRESS;
        register_write_from = DATA_MEMORY;
        write_mem_enable = 1'b0;
        write_reg_enable = 1'b1;
        set_pc = 1'b0;
        immediate = {{20{raw_src[24]}}, raw_src[24:13]};
      end

      OPCODE_BRANCH: begin
        case (func3)
          F3_BEQ, F3_BNE: alu_control = {ALU_SUB, R1_R2};
          F3_BLT, F3_BGE: alu_control = {ALU_SLT, R1_R2};
          F3_BLTU, F3_BGEU: alu_control = {ALU_SLTU, R1_R2};
          default: alu_control = {ALU_DEFAULT, R1_R2};
        endcase
        alu_out_goto = JUMP;
        register_write_from = NOT_WRITE;
        write_mem_enable = 1'b0;
        write_reg_enable = 1'b0;
        set_pc = 1'b1;
        immediate = {{20{raw_src[24]}}, raw_src[0], raw_src[23:18], raw_src[4:1], 1'b0};
      end

      OPCODE_JAL: begin
        alu_control = {ALU_ADD, R1_IMM};
        alu_out_goto = JUMP;
        register_write_from = PC_PLUS_4;
        immediate = {{12{raw_src[24]}}, raw_src[12:5], raw_src[13], raw_src[23:14], 1'b0};
      end

      OPCODE_JALR: begin
        alu_control = {ALU_ADD, R1_IMM};
        alu_out_goto = JUMP;
        register_write_from = PC_PLUS_4;
        immediate = {20'b0, raw_src[11:0]};
      end

      default: begin
        alu_control = 'x;
        alu_out_goto = 'x;
        register_write_from = 'x;
        immediate = 'x;
      end
    endcase
  end

endmodule
