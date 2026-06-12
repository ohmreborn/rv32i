`ifndef decode
`define decode

`define FETCH 2'b00
`define WAIT_FETCH  2'b01
`define EXEC  2'b10
`define WAIT_DATA  2'b11

`define OPCODE_IMM_ALU  7'b0010011
`define OPCODE_LUI      7'b0110111
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_R_R_INT  7'b0110011
`define OPCODE_STORE    7'b0100011
`define OPCODE_LOAD     7'b0000011
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_JAL      7'b1101111
`define OPCODE_JALR     7'b1100111

`define F3_BEQ   3'b000
`define F3_BNE   3'b001
`define F3_BLT   3'b100
`define F3_BGE   3'b101
`define F3_BLTU  3'b110
`define F3_BGEU  3'b111

`define F3_SB  3'b000
`define F3_SH  3'b001
`define F3_SW  3'b010

`define F3_LB   3'b000
`define F3_LH   3'b001
`define F3_LW   3'b010
`define F3_LBU  3'b100
`define F3_LHU  3'b101

`define F3_ADDI  3'b000
`define F3_SLTI  3'b010
`define F3_SLTIU  3'b011
`define F3_XORI  3'b100
`define F3_ORI  3'b110
`define F3_ANDI  3'b111
`define F3_SLLI  3'b001
`define F3_SRLI_SRAI  3'b101

`define F3_ADD_SUB  3'b000
`define F3_SLL  3'b001
`define F3_SLT  3'b010
`define F3_SLTU  3'b011
`define F3_XOR  3'b100
`define F3_SRL_SRA  3'b101
`define F3_OR  3'b110
`define F3_AND  3'b111

`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_SLL  4'b0010
`define ALU_SLT  4'b0100
`define ALU_SLTU  4'b0110
`define ALU_XOR  4'b1000
`define ALU_SRL  4'b1010
`define ALU_SRA  4'b1011
`define ALU_OR  4'b1100
`define ALU_AND  4'b1110
`define ALU_R0_IMM  4'b1111

`define PC_IMM  2'b00
`define PC_R2   2'b01
`define R1_IMM  2'b10
`define R1_R2   2'b11

`define REGISTER  2'b00
`define JUMP  2'b01
`define WRITE_MEMORY_ADDRESS  2'b10
`define READ_MEMORY_ADDRESS  2'b11

`define NOT_WRITE  2'b00
`define ALU_OUT  2'b01
`define DATA_MEMORY  2'b10
`define PC_PLUS_4  2'b11

`endif