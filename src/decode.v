typedef enum logic [1:0] {
  FETCH = 2'b00,
  WAIT_FETCH = 2'b01,
  EXEC = 2'b10,
  WAIT_DATA = 2'b11
} state_t;

typedef enum logic [6:0] {
  OPCODE_IMM_ALU = 7'b0010011,
  OPCODE_LUI     = 7'b0110111,
  OPCODE_AUIPC   = 7'b0010111,
  OPCODE_R_R_INT = 7'b0110011,
  OPCODE_STORE   = 7'b0100011,
  OPCODE_LOAD    = 7'b0000011,
  OPCODE_BRANCH  = 7'b1100011,
  OPCODE_JAL     = 7'b1101111,
  OPCODE_JALR    = 7'b1100111
} opcode_t;

typedef enum logic [2:0] {
  F3_BEQ  = 3'b000,
  F3_BNE  = 3'b001,
  F3_BLT  = 3'b100,
  F3_BGE  = 3'b101,
  F3_BLTU = 3'b110,
  F3_BGEU = 3'b111
} branch_func3_t;

typedef enum logic [2:0] {
  F3_SB = 3'b000,
  F3_SH = 3'b001,
  F3_SW = 3'b010
} store_func3_t;

typedef enum logic [2:0] {
  F3_LB  = 3'b000,
  F3_LH  = 3'b001,
  F3_LW  = 3'b010,
  F3_LBU = 3'b100,
  F3_LHU = 3'b101
} load_func3_t;

typedef enum logic [2:0] {
  F3_ADDI = 3'b000,
  F3_SLTI = 3'b010,
  F3_SLTIU = 3'b011,
  F3_XORI = 3'b100,
  F3_ORI = 3'b110,
  F3_ANDI = 3'b111,
  F3_SLLI = 3'b001,
  F3_SRLI_SRAI = 3'b101
} math_immediate_func3_t;

typedef enum logic [2:0] {
  F3_ADD_SUB = 3'b000,
  F3_SLL = 3'b001,
  F3_SLT = 3'b010,
  F3_SLTU = 3'b011,
  F3_XOR = 3'b100,
  F3_SRL_SRA = 3'b101,
  F3_OR = 3'b110,
  F3_AND = 3'b111
} math_f3_t;

typedef enum logic [3:0] {
  ALU_ADD = 4'b0000,
  ALU_SUB = 4'b0001,
  ALU_SLL = 4'b0010,
  ALU_SLT = 4'b0100,
  ALU_SLTU = 4'b0110,
  ALU_XOR = 4'b1000,
  ALU_SRL = 4'b1010,
  ALU_SRA = 4'b1011,
  ALU_OR = 4'b1100,
  ALU_AND = 4'b1110,
  ALU_R0_IMM = 4'b1111
} alu_func_control_t;

typedef enum logic [1:0] {
  PC_IMM = 2'b00,
  PC_R2  = 2'b01,
  R1_IMM = 2'b10,
  R1_R2  = 2'b11
} chose_alu_input_t;

typedef enum logic [1:0] {
  REGISTER = 2'b00,
  JUMP = 2'b01,
  WRITE_MEMORY_ADDRESS = 2'b01,
  READ_MEMORY_ADDRESS = 2'b11
} alu_out_goto_t;

typedef enum logic [1:0] {
  NOT_WRITE = 2'b00,
  ALU_OUT = 2'b01,
  DATA_MEMORY = 2'b10,
  PC_PLUS_4 = 2'b11
} register_write_from_t;
