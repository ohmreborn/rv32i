module control_unit (
    input wire [31:0] machine_code,

    output wire [31:0] immediate,
    output wire [6:0]  opcode,
    output wire [4:0]  r1_address,
    output wire [4:0]  r2_address,
    output wire [4:0]  rd_address,
    output wire [5:0]  alu_control,
    output wire [2:0]  mem_address_mode,
    output wire [1:0]  load_or_store,
    output wire        register_write_from,
    output wire        write_reg_enable,
    output wire        branch_mode,
    output wire        is_branch,
    output wire        is_jump
);

    wire [6:0] opcode_w   = machine_code[6:0];
    wire [2:0] func3      = machine_code[14:12];
    wire [6:0] func7      = machine_code[31:25];

    assign opcode     = opcode_w;
    assign r1_address = (opcode_w == `OPCODE_LUI) ? 5'b0 : machine_code[19:15];
    assign r2_address = machine_code[24:20];
    assign rd_address = machine_code[11:7];

    // ── immediate ────────────────────────────────────────────────
    wire [31:0] IShamt = {{27{machine_code[24]}}, machine_code[24:20]};
    wire [31:0] Iimm={{21{machine_code[31]}}, machine_code[30:20]};
    wire [31:0] Simm={{21{machine_code[31]}}, machine_code[30:25],  machine_code[11:7]};
    wire [31:0] Bimm={{20{machine_code[31]}}, machine_code[7],      machine_code[30:25],    machine_code[11:8],  1'b0};
    wire [31:0] Uimm={    machine_code[31],   machine_code[30:12],  {12{1'b0}}};
    wire [31:0] Jimm={{12{machine_code[31]}}, machine_code[19:12],  machine_code[20],       machine_code[30:21], 1'b0};

    wire IsIShamttype = opcode_w == `OPCODE_IMM_ALU && (func3 == `F3_SLLI || func3 == `F3_SRLI_SRAI);
    wire IsItype = (opcode_w == `OPCODE_IMM_ALU) || (opcode_w == `OPCODE_LOAD || opcode_w == `OPCODE_JALR);
    wire IsStype = (opcode_w == `OPCODE_STORE);
    wire IsBtype = (opcode_w == `OPCODE_BRANCH);
    wire IsUtype = (opcode_w == `OPCODE_AUIPC) || (opcode_w == `OPCODE_LUI);
    wire IsJtype = (opcode_w == `OPCODE_JAL);
    wire IsRtype = (opcode_w == `OPCODE_R_R_INT);
    assign immediate = 
        IsIShamttype
            ? IShamt
        : IsItype
            ? Iimm
        : IsStype
            ? Simm
        : IsBtype
            ? Bimm
        : IsUtype
            ? Uimm
        : IsJtype
            ? Jimm
        : 32'b0;

    // ── alu_control ──────────────────────────────────────────────
    assign alu_control =
        (opcode_w == `OPCODE_IMM_ALU && (func3 == `F3_SLLI || func3 == `F3_SRLI_SRAI))
            ? {func3, func7[1], `R1_IMM}
        : (opcode_w == `OPCODE_IMM_ALU)
            ? {func3, 1'b0, `R1_IMM}
        : (opcode_w == `OPCODE_R_R_INT)
            ? {func3, func7[1], `R1_R2}
        : (opcode_w == `OPCODE_BRANCH && (func3 == `F3_BEQ || func3 == `F3_BNE))
            ? {`ALU_SUB, `R1_R2}
        : (opcode_w == `OPCODE_BRANCH && (func3 == `F3_BLT || func3 == `F3_BGE))
            ? {`ALU_SLT, `R1_R2}
        : (opcode_w == `OPCODE_BRANCH)
            ? {`ALU_SLTU, `R1_R2}
        : (opcode_w == `OPCODE_AUIPC || opcode_w == `OPCODE_JAL)
            ? {`ALU_ADD, `PC_IMM}
        : {`ALU_ADD, `R1_IMM};   // LUI, LOAD, STORE, JALR

    // ── branch_mode ──────────────────────────────────────────────
    assign branch_mode =
        (opcode_w == `OPCODE_BRANCH && (func3 == `F3_BNE || func3 == `F3_BGE || func3 == `F3_BGEU))
            ? 1'b1 : 1'b0;

    // ── mem / load_or_store ──────────────────────────────────────
    assign mem_address_mode =
        (opcode_w == `OPCODE_LOAD || opcode_w == `OPCODE_STORE) ? func3 : 3'b0;

    assign load_or_store =
        (opcode_w == `OPCODE_LOAD)  ? `LOAD_MEMORY_ADDRESS  :
        (opcode_w == `OPCODE_STORE) ? `STORE_MEMORY_ADDRESS :
        `NOT_LOAD_STORE;

    // ── register write ───────────────────────────────────────────
    assign write_reg_enable =
        (opcode_w == `OPCODE_STORE || opcode_w == `OPCODE_BRANCH) ? 1'b0 : 1'b1;

    assign register_write_from =
        (opcode_w == `OPCODE_JAL || opcode_w == `OPCODE_JALR) ? `PC_PLUS_4 : `ALU_OUT;

    // ── jump / branch flags ──────────────────────────────────────
    assign is_branch = (opcode_w == `OPCODE_BRANCH);
    assign is_jump   = (opcode_w == `OPCODE_JAL || opcode_w == `OPCODE_JALR);

endmodule