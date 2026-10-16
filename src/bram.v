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
  wire [31:0] ra = {mem[12'hff8], mem[12'hff9], mem[12'hffa], mem[12'hffb]};
  wire [31:0] ra1 = {mem[12'hfe8], mem[12'hfe9], mem[12'hfea], mem[12'hfeb]};


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
