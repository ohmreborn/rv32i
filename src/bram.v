module bram #(
    parameter MemInit,
    parameter integer MEMSIZE = 4096
) (
    input wire clk,
    input wire reset,

    // CPU Bus Interface
    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [ 7:0] mem_wdata,
    input  wire        mem_we,
    output reg  [ 7:0] mem_rdata,
    output reg         mem_ready

);

  reg [7:0] mem[0:MEMSIZE-1];

  initial begin
    $readmemh(MemInit, mem);
  end

  always @(posedge clk) begin
    if (reset) begin
      mem_ready <= 1'b0;
    end else if (mem_valid && !mem_ready) begin
      if (mem_we) begin
        mem[mem_addr] <= mem_wdata;
      end
      mem_rdata <= mem[mem_addr];
      mem_ready <= 1'b1;
    end else begin
      mem_ready <= 1'b0;
    end
  end


endmodule
