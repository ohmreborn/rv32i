module csr(
    input wire clk,
    input wire reset,
    input wire [4:0] uimm,
    input wire [11:0] csr_address,
    input wire [31:0] csr_value,
    input wire write_enable,
    output reg [31:0] csr_out,

    input wire [31:0] pc_in,
    input wire is_mret,
    input wire [2:0] cpu_state,
    input wire [4:0] irq,
    input wire trap,
    output reg [31:0] next_instruction_address,
    output wire do_trap
    
);
    assign do_trap = csr[`LOCAL_MSTATUS][`MSTATUS_MIE_POS] && trap;

    // csr register
    reg [31:0] csr [0:7];
    wire [31:0] mstatus = csr[`LOCAL_MSTATUS];
    wire [31:0] mie = csr[`LOCAL_MIE];
    wire [31:0] mtvec = csr[`LOCAL_MTVEC];
    wire [31:0] mstatush = csr[`LOCAL_MSTATUSH];
    wire [31:0] mscratch = csr[`LOCAL_MSCRATCH];
    wire [31:0] mepc = csr[`LOCAL_MEPC];
    wire [31:0] mcause = csr[`LOCAL_MCAUSE];
    wire [31:0] mip = csr[`LOCAL_MIP];
    wire [2:0] local_csr_address = (csr_address == `MSTATUS) ? `LOCAL_MSTATUS
        : (csr_address == `MIE) ? `LOCAL_MIE
        : (csr_address == `MTVEC) ? `LOCAL_MTVEC
        : (csr_address == `MSTATUSH) ? `LOCAL_MSTATUSH
        : (csr_address == `MSCRATCH) ? `LOCAL_MSCRATCH
        : (csr_address == `MEPC) ? `LOCAL_MEPC
        : (csr_address == `MCAUSE) ? `LOCAL_MCAUSE
        : (csr_address == `MIP) ? `LOCAL_MIP
        : 3'bx;

    always @(posedge clk) begin
        if (reset) begin
            csr[`LOCAL_MSTATUS] <= (`MSTATUS_MPP | `MSTATUS_MIE) ;
            csr[`LOCAL_MIE] <= 32'b1;
            csr[`LOCAL_MTVEC] <= 32'b0;
            csr[`LOCAL_MSTATUSH] <= 32'b0;
            csr[`LOCAL_MSCRATCH] <= 32'b0;
            csr[`LOCAL_MEPC] <= 32'b0;
            csr[`LOCAL_MCAUSE] <= 32'b0;
            csr[`LOCAL_MIP] <= 32'b0;
        end else begin

            if (is_mret && cpu_state == `DECODE) begin
                csr[`LOCAL_MSTATUS][`MSTATUS_MIE_POS] <= csr[`LOCAL_MSTATUS][`MSTATUS_MPIE_POS];
                csr[`LOCAL_MSTATUS][`MSTATUS_MPIE_POS] <= 1;
                next_instruction_address <= csr[`LOCAL_MEPC];
            end else if (do_trap && cpu_state == `DECODE) begin
                csr[`LOCAL_MCAUSE] <= irq;
                csr[`LOCAL_MEPC] <= pc_in;
                next_instruction_address <= csr[`LOCAL_MTVEC] + (irq<<2);
                csr[`LOCAL_MSTATUS][`MSTATUS_MIE_POS] <= 1'b0;
                csr[`LOCAL_MSTATUS][`MSTATUS_MPIE_POS] <= csr[`LOCAL_MSTATUS][`MSTATUS_MIE_POS];
            end else begin
                csr_out <= csr[local_csr_address];
                if (write_enable && cpu_state == `EXEC) begin
		            csr[local_csr_address] <= csr_value;
                end
            end
        end
    end


// mret
    // mie <= mpie
    // mpie <= 1
    // pc <= mepc

// mie
    // meie
    // mtie
// mip
    // meip
    // mtip
// mcause
    // interupt
        // Timer interupt
        // External interupt
    // exception
        // Ecall M mode


// Mcycle [63:0];
// mcycle
    // assign mcycle = Mcycle[31:0];
// mcycleh
    // assign mcycle = Mcycle[63:32];

// interupt 

endmodule
