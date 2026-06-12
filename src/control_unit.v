`include "/Users/krittiwitkampradam/Documents/myrisc-v-101/multi-cycle/src/decode.v"

module control_unit (
    input wire clk,
    input wire [31:0] machine_code,

    output reg [31:0] immediate,

    output reg [6:0] opcode,
    output reg [4:0] r1_address,
    output reg [4:0] r2_address,
    output reg [4:0] rd_address,
    output reg [5:0] alu_control,
    output reg [1:0] alu_out_goto,
    output reg [1:0] register_write_from,

    output reg write_mem_enable,
    output reg write_reg_enable,
    output reg set_pc
);

  reg [2:0] func3;
  reg [6:0] func7;
  always_ff @(posedge clk) begin
    opcode <= machine_code[6:0];
    func3 <= machine_code[14:12];
    func7 <= machine_code[31:25];
    r1_address <= (opcode == `OPCODE_LUI) ? 5'b00000 : machine_code[19:15];
    r2_address <= machine_code[24:20];
    rd_address <= machine_code[11:7];
    if (opcode == `OPCODE_IMM_ALU) begin
        // opcode, func3, func7, r1, rd
        alu_control <= {{func3, func7[1]}, `R1_IMM};
        alu_out_goto <= `REGISTER;
        register_write_from <= `ALU_OUT;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b1;
        set_pc = 1'b0;
        if ((func3 == `F3_ADDI) || (func3 == `F3_SLTIU) || (func3 == `F3_XORI) || (func3 == `F3_ORI) || (func3 == `F3_ANDI)) begin
            immediate <= {{20{machine_code[24]}}, machine_code[24:13]};
        end
        if ((func3 == `F3_ADDI) || (func3 == `F3_ADDI)) begin 
          immediate <= {{27'b0}, machine_code[24:20]};
        end
      end

      else if (opcode == `OPCODE_AUIPC) begin
        // opcode, rd
        alu_control <= {{`ALU_ADD}, `PC_IMM};
        alu_out_goto <= `REGISTER;
        register_write_from <= `ALU_OUT;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b1;
        set_pc <= 1'b0;
        immediate <= {machine_code[24:5], 12'b0};
      end

      else if (opcode == `OPCODE_LUI) begin
        // opcode, rd
        // r1 = r0
        alu_control <= {{`ALU_ADD}, `R1_IMM};
        alu_out_goto <= `REGISTER;
        register_write_from <= `ALU_OUT;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b1;
        set_pc <= 1'b0;
        immediate <= {machine_code[24:5], 12'b0};
      end

      else if (opcode == `OPCODE_R_R_INT) begin
        // opcode, func3, func7, r1, r2, rd
        alu_control <= {{func3, func7[1]}, `R1_R2};
        alu_out_goto <= `REGISTER;
        register_write_from <= `ALU_OUT;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b1;
        set_pc <= 1'b0;
        immediate <= 'x;  // not care
      end

      else if (opcode == `OPCODE_STORE) begin
        // opcode, func3, r1, r2
        alu_control <= {`ALU_ADD, `R1_IMM};
        alu_out_goto <= `WRITE_MEMORY_ADDRESS;
        register_write_from <= `NOT_WRITE;
        write_mem_enable <= 1'b1;
        write_reg_enable <= 1'b0;
        set_pc <= 1'b0;
        immediate <= {{20{machine_code[24]}}, machine_code[24:18], machine_code[4:0]};
      end

      else if (opcode == `OPCODE_LOAD) begin
        // opcode, func3, r1, rd
        alu_control <= {`ALU_ADD, `R1_IMM};
        alu_out_goto <= `READ_MEMORY_ADDRESS;
        register_write_from <= `DATA_MEMORY;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b1;
        set_pc <= 1'b0;
        immediate <= {{20{machine_code[24]}}, machine_code[24:13]};
      end

      else if (opcode == `OPCODE_BRANCH) begin
        // opcode, func3, r1, r2
        if ((func3 == `F3_BEQ) || (func3 == `F3_BNE)) begin
          alu_control <= {`ALU_SUB, `R1_R2};
        end
        if ((func3 == `F3_BLT) || (func3 == `F3_BGE)) begin
          alu_control <= {`ALU_SUB, `R1_R2};
        end
        if ((func3 == `F3_BLTU) || (func3 == `F3_BGEU)) begin
          alu_control <= {`ALU_SUB, `R1_R2};
        end
        alu_out_goto <= `JUMP;
        register_write_from <= `NOT_WRITE;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b0;
        set_pc <= 1'b1;
        immediate <= {{20{machine_code[24]}}, machine_code[0], machine_code[23:18], machine_code[4:1], 1'b0};
      end

      else if (opcode == `OPCODE_JAL) begin
        // opcode, func3, rd
        alu_control <= {`ALU_ADD, `R1_IMM};
        alu_out_goto <= `JUMP;
        register_write_from <= `PC_PLUS_4;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b0;
        set_pc <= 1'b1;
        immediate <= {{12{machine_code[24]}}, machine_code[12:5], machine_code[13], machine_code[23:14], 1'b0};
      end

      else if (opcode == `OPCODE_JALR) begin
        // opcode, func3, r1, rd
        alu_control <= {`ALU_ADD, `R1_IMM};
        alu_out_goto <= `JUMP;
        register_write_from <= `PC_PLUS_4;
        write_mem_enable <= 1'b0;
        write_reg_enable <= 1'b1;
        set_pc <= 1'b1;
        immediate <= {20'b0, machine_code[11:0]};
      end

      else begin
        alu_control <= 5'bxxxx;
        alu_out_goto <= 2'bxx;
        register_write_from <= 2'bxx;
        write_mem_enable <= 1'bx;
        write_reg_enable <= 1'bx;
        set_pc <= 1'bx;
        immediate <= 32'bx;
      end
  end

endmodule
