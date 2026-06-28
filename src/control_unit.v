module control_unit (
    input wire [31:0] machine_code,

    output reg [31:0] immediate,

    output reg [6:0] opcode,
    output reg [4:0] r1_address,
    output reg [4:0] r2_address,
    output reg [4:0] rd_address,
    output reg [5:0] alu_control,

    output reg [2:0] mem_address_mode,
    output reg [1:0] load_or_store,

    output reg register_write_from,
    output reg write_reg_enable,

    output reg branch_mode,
    output reg is_branch,
    output reg is_jump
);

    reg [2:0] func3;
    reg [6:0] func7;
    always @(*) begin
        opcode = machine_code[6:0];
        func3 = machine_code[14:12];
        func7 = machine_code[31:25];
        r1_address = (opcode == `OPCODE_LUI) ? 5'b00000 : machine_code[19:15];
        r2_address = machine_code[24:20];
        rd_address = machine_code[11:7];
        if (opcode == `OPCODE_IMM_ALU) begin
            // opcode, func3, func7, r1, rd
            if ((func3 == `F3_ADDI) || (func3 == `F3_SLTI) || (func3 == `F3_SLTIU) || (func3 == `F3_XORI) || (func3 == `F3_ORI) || (func3 == `F3_ANDI)) begin
                immediate = {{25{machine_code[31]}}, machine_code[31:20]};
                alu_control = {func3, 1'b0, `R1_IMM};
            end
            else if ((func3 == `F3_SLLI) || (func3 == `F3_SRLI_SRAI)) begin 
                immediate = {{27{machine_code[24]}}, machine_code[24:20]};
                alu_control = {func3, func7[1], `R1_IMM};
            end
            else begin
                immediate = 32'b0;
                alu_control = 6'b0;
            end

            register_write_from = `ALU_OUT;
            write_reg_enable = 1'b1;

            mem_address_mode = 3'bxxx;
            load_or_store = `NOT_LOAD_STORE;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b0;
        end 
        else if (opcode == `OPCODE_AUIPC) begin
            // opcode, rd
            alu_control = {{`ALU_ADD}, `PC_IMM};
            immediate = {machine_code[31:12], 12'b0};

            register_write_from = `ALU_OUT;
            write_reg_enable = 1'b1;

            mem_address_mode = 3'bxxx;
            load_or_store = `NOT_LOAD_STORE;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b0;
        end 
        else if (opcode == `OPCODE_LUI) begin
            // opcode, rd
            // r1 = r0
            alu_control = {{`ALU_ADD}, `R1_IMM};
            immediate = {machine_code[31:12], 12'b0};

            register_write_from = `ALU_OUT;
            write_reg_enable = 1'b1;

            mem_address_mode = 3'bxxx;
            load_or_store = `NOT_LOAD_STORE;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b0;
        end 
        else if (opcode == `OPCODE_R_R_INT) begin
            // opcode, func3, func7, r1, r2, rd
            alu_control = {{func3, func7[1]}, `R1_R2};
            immediate = 32'bx;

            register_write_from = `ALU_OUT;
            write_reg_enable = 1'b1;

            mem_address_mode = 3'bxxx;
            load_or_store = `NOT_LOAD_STORE;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b0;
        end 
        else if (opcode == `OPCODE_STORE) begin
            // opcode, func3, r1, r2
            alu_control = {`ALU_ADD, `R1_IMM};
            immediate = {{20{machine_code[31]}}, machine_code[31:25], machine_code[11:7]};

            register_write_from = 1'bx;
            write_reg_enable = 1'b0;

            mem_address_mode = func3;
            load_or_store = `STORE_MEMORY_ADDRESS;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b0;
        end 
        else if (opcode == `OPCODE_LOAD) begin
            // opcode, func3, r1, rd
            alu_control = {`ALU_ADD, `R1_IMM};
            immediate = {{20{machine_code[31]}}, machine_code[31:20]};

            register_write_from = 1'bx;
            write_reg_enable = 1'b1;

            mem_address_mode = func3;
            load_or_store = `LOAD_MEMORY_ADDRESS;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b0;
        end 
        else if (opcode == `OPCODE_BRANCH) begin
            // opcode, func3, r1, r2
            if ((func3 == `F3_BEQ) || (func3 == `F3_BNE)) begin
                alu_control = {`ALU_SUB, `R1_R2};
                branch_mode = (func3 == `F3_BNE);
            end
            else if ((func3 == `F3_BLT) || (func3 == `F3_BGE)) begin
                alu_control = {`ALU_SLT, `R1_R2};
                branch_mode = (func3 == `F3_BLT);
            end
            else if ((func3 == `F3_BLTU) || (func3 == `F3_BGEU)) begin
                alu_control = {`ALU_SLTU, `R1_R2};
                branch_mode = (func3 == `F3_BLTU);
            end
            else  begin
                alu_control = 6'b0;
                branch_mode = 0;
            end
            immediate = {{20{machine_code[24]}}, machine_code[0], machine_code[23:18], machine_code[4:1], 1'b0};

            register_write_from = 1'bx;
            write_reg_enable = 1'b0;

            mem_address_mode = 3'bxxx;
            load_or_store = `NOT_LOAD_STORE;

            is_branch = 1'b1;
            is_jump = 1'b0;
        end 
        else if (opcode == `OPCODE_JAL) begin
            // opcode, func3, rd
            alu_control = {`ALU_ADD, `PC_IMM};
            immediate = {{12{machine_code[31]}}, machine_code[19: 12], machine_code[20], machine_code[30:21], 1'b0};

            register_write_from = `PC_PLUS_4;
            write_reg_enable = 1'b1;

            mem_address_mode = 3'bxxx;
            load_or_store = `NOT_LOAD_STORE;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b1;
        end 
        else if (opcode == `OPCODE_JALR) begin
            // opcode, func3, r1, rd
            alu_control = {`ALU_ADD, `R1_IMM};
            immediate = {{20{machine_code[31]}}, machine_code[11:0]};

            register_write_from = `PC_PLUS_4;
            write_reg_enable = 1'b1;

            mem_address_mode = 3'bxxx;
            load_or_store = `NOT_LOAD_STORE;

            branch_mode = 1'bx;
            is_branch = 1'b0;
            is_jump = 1'b1;
        end 
        else begin
            alu_control = 5'bx;
            immediate = 32'bx;

            register_write_from = 1'bx;
            write_reg_enable = 1'bx;

            mem_address_mode = 3'bxxx;
            load_or_store = 2'bx;

            branch_mode = 1'bx;
            is_branch = 1'bx;
            is_jump = 1'bx;
        end
    end

endmodule
