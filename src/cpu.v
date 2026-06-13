module cpu (
    output reg        mem_valid,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    output reg [ 3:0] mem_wstrb,
    input  reg [31:0] mem_rdata
    input  reg        mem_ready
);

endmodule
