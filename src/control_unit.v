module control_unit (
    input wire [31:0] machine_code,

    output wire [31:0] immediate,
    output wire [6:0]  opcode,
    output wire [4:0]  rs1_addr_uimm,
    output wire [4:0]  r2_address,
    output wire [4:0]  rd_address,

    output wire [11:0] csr_address,
    output wire [5:0]  alu_control,
    output wire [2:0]  mem_address_mode,
    output wire [1:0]  load_or_store,
    output wire [1:0]  register_write_from,
    output wire        write_reg_enable,
    output wire        write_csr_enable,
    output wire        branch_mode,
    output wire        is_branch,
    output wire        is_jump,
    output wire        is_mret
);
    assign is_mret = (machine_code == `IS_MRET);

    wire [6:0] opcode_w   = machine_code[6:0];
    wire [6:0] func7      = machine_code[31:25];
    wire [2:0] func3      = machine_code[14:12];


    assign opcode     = opcode_w;
    assign rs1_addr_uimm = (opcode_w == `OPCODE_LUI) ? 5'b0 : machine_code[19:15];
    assign r2_address = machine_code[24:20];
    assign rd_address = machine_code[11:7];

    // ── immediate ────────────────────────────────────────────────
    wire [31:0] Uimm={machine_code[31:12], {12{1'b0}}};
    wire [31:0] Jimm={{12{machine_code[31]}}, machine_code[19:12], machine_code[20], machine_code[30:21], 1'b0};
    wire [31:0] Bimm={{20{machine_code[31]}}, machine_code[7], machine_code[30:25], machine_code[11:8],  1'b0};
    wire [31:0] IShamt = {{27{machine_code[24]}}, machine_code[24:20]};
    wire [31:0] Iimm={{20{machine_code[31]}}, machine_code[31:20]};
    wire [31:0] Simm={{20{machine_code[31]}}, machine_code[31:25], machine_code[11:7]};

    wire IsLUItype    = opcode_w == `OPCODE_LUI;
    wire IsAUIPCtype  = opcode_w == `OPCODE_AUIPC;
    wire IsJtype      = opcode_w == `OPCODE_JAL;
    wire IsJALRtype   = opcode_w == `OPCODE_JALR;
    wire IsBtype      = opcode_w == `OPCODE_BRANCH;
    wire IsLoadtype   = opcode_w == `OPCODE_LOAD;
    wire IsStype      = opcode_w == `OPCODE_STORE;
    wire IsImmALUtype = opcode_w == `OPCODE_IMM_ALU;
    wire IsIShamttype = opcode_w == `OPCODE_IMM_ALU && (func3 == `F3_SLLI || func3 == `F3_SRLI_SRAI);
    wire IsRtype      = opcode_w == `OPCODE_R_R_INT;
    wire IsSystem     = opcode_w == `OPCODE_SYSTEM;
    
    assign immediate = 
        (IsLUItype || IsAUIPCtype) ? Uimm 
        : (IsJtype) ? Jimm 
        : (IsBtype) ? Bimm 
        : (IsIShamttype) ? IShamt 
        : (IsLoadtype || IsJALRtype || IsImmALUtype) ? Iimm 
        : (IsStype) ? Simm 
        : (IsSystem && (func3 == `F3_CSRRWI || func3 == `F3_CSRRSI || func3 == `F3_CSRRCI)) ? ~rs1_addr_uimm
        : (IsSystem) ? 32'b0
        : 32'bx;

    // ── alu_control ──────────────────────────────────────────────
    assign alu_control =
        (IsIShamttype) ? {func3, func7[1], `R1_IMM}
        : (IsImmALUtype) ? {func3, 1'b0, `R1_IMM}
        : (IsRtype) ? {func3, func7[1], `R1_R2}
        : (IsBtype && (func3 == `F3_BEQ || func3 == `F3_BNE)) ? {`ALU_SUB, `R1_R2}
        : (IsBtype && (func3 == `F3_BLT || func3 == `F3_BGE)) ? {`ALU_SLT, `R1_R2}
        : (IsBtype) ? {`ALU_SLTU, `R1_R2}
        : (IsAUIPCtype || IsJtype) ? {`ALU_ADD, `PC_IMM}
        : (IsLUItype || IsLoadtype || IsStype || IsStype || IsJALRtype) ? {`ALU_ADD, `R1_IMM} 
        // rd <= csr
        // csr <= rs1 + 0
        : (IsSystem && (func3 == `F3_CSRRW)) ? {`ALU_ADD, `R1_IMM}
        // rd <= csr
        // csr <= rs1 | csr
        : (IsSystem && (func3 == `F3_CSRRS)) ? {`ALU_OR, `R1_R2}
        // rd <= csr
        // csr <= ~rs1 & csr
        : (IsSystem && (func3 == `F3_CSRRC)) ? {`ALU_AND, `R1_R2}
        : (IsSystem && (func3 == `F3_CSRRWI)) ? {`ALU_ADD, `R1_IMM}
        : (IsSystem && (func3 == `F3_CSRRSI)) ? {`ALU_OR, `R1_IMM}
        : (IsSystem && (func3 == `F3_CSRRCI)) ? {`ALU_AND, `R1_IMM}
        : 6'bx;

    // ── branch_mode ──────────────────────────────────────────────
    assign branch_mode =
        (IsBtype && (func3 == `F3_BNE || func3 == `F3_BGE || func3 == `F3_BGEU))
            ? 1'b1 : 1'b0;

    // ── mem / load_or_store ──────────────────────────────────────
    assign mem_address_mode = func3;

    assign load_or_store =
        (IsLoadtype)  ? `LOAD_MEMORY_ADDRESS  
        : (IsStype) ? `STORE_MEMORY_ADDRESS 
        : `NOT_LOAD_STORE;

    // ── register write ───────────────────────────────────────────
    assign write_reg_enable = (IsStype || IsBtype) ? 1'b0 : 1'b1;

    assign register_write_from =
        (IsJtype || IsJALRtype) ? `PC_PLUS_4 
        : (IsSystem) ? `CSR
        : `ALU_OUT;

    assign write_csr_enable = IsSystem;
    // ── jump / branch flags ──────────────────────────────────────
    assign is_branch = IsBtype;
    assign is_jump   = IsJtype || IsJALRtype;

    assign csr_address = machine_code[31:20];

endmodule
