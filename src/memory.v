module memory #(
    parameter MemInit = "../firmware/build/load.hex",
    parameter MEMSIZE = 256 
) (
    input  wire        clk,
    input  wire        reset,

    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [ 3:0] mem_wstrb,
    output reg  [31:0] mem_rdata,
    output reg         mem_ready,

    output wire [4:0] LED
);

    (* ram_style = "registers" *) reg [31:0] main_memory [0:MEMSIZE-1];
    reg [31:0] LEDS_MAPS;
    assign LED = LEDS_MAPS[4:0];


    initial begin
        $readmemh(MemInit, main_memory);
    end

    wire [31:0] word_addr = mem_addr[31:2];  // word-aligned index

    always @(posedge clk) begin
        if (reset) begin
            mem_ready <= 1'b0;
            mem_rdata <= 32'b0;
        end
        else begin
            // De-assert ready by default unless a new transaction completes
            // Fixed memory range check to avoid out-of-bounds indexing
            if (mem_valid && !mem_ready) begin
                if (word_addr < MEMSIZE) begin
                    if (mem_wstrb == 4'b0000) begin
                        // READ: return data and assert ready same cycle
                        mem_rdata <= main_memory[word_addr];
                        mem_ready <= 1'b1;
                    end
                    else begin
                        // WRITE: apply byte strobes
                        if (mem_wstrb[0]) main_memory[word_addr][ 7: 0] <= mem_wdata[ 7: 0];
                        if (mem_wstrb[1]) main_memory[word_addr][15: 8] <= mem_wdata[15: 8];
                        if (mem_wstrb[2]) main_memory[word_addr][23:16] <= mem_wdata[23:16];
                        if (mem_wstrb[3]) main_memory[word_addr][31:24] <= mem_wdata[31:24];
                        mem_ready <= 1'b1;
                    end
                end
                else if (word_addr == 32'h400) begin
                    if (mem_wstrb == 4'b0000) begin
                        // READ
                        mem_rdata <= LEDS_MAPS;
                        mem_ready <= 1'b1;
                    end
                    else begin
                        // WRITE
                        if (mem_wstrb[0]) LEDS_MAPS[ 7: 0] <= mem_wdata[ 7: 0];
                        if (mem_wstrb[1]) LEDS_MAPS[15: 8] <= mem_wdata[15: 8];
                        if (mem_wstrb[2]) LEDS_MAPS[23:16] <= mem_wdata[23:16];
                        if (mem_wstrb[3]) LEDS_MAPS[31:24] <= mem_wdata[31:24];
                        mem_ready <= 1'b1;
                    end
                end
            end
            else begin
                mem_ready <= 1'b0; 
            end
        end
    end

endmodule