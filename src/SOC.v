module SOC (
    input wire clk,
    input wire reset,
    output wire [4:0] LED
);
    reg         mem_valid;
    reg  [31:0] mem_addr;
    reg  [31:0] mem_wdata;
    reg  [ 3:0] mem_wstrb;
    wire  [31:0] mem_rdata;
    wire        mem_ready;

    cpu CPU (
        .clk(clk),
        .reset(reset),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready)
    );

    memory #(
        .MemInit("../firmware/build/load.hex"),
        .MEMSIZE(4096)
    ) mem (
        .clk(clk),
        .reset(reset),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready),

        .LED(LED)
    );


endmodule
