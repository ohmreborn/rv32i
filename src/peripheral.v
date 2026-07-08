module peripheral (
    input wire clk,
    input wire reset,

    // CPU Bus Interface
    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [ 7:0] mem_wdata,
    input  wire        mem_we,
    output reg  [ 7:0] mem_rdata,
    output reg         mem_ready,

    output wire [4:0] LED
);

  reg [7:0] mem[4:0];
  wire [31:0] address;
  assign address = mem_addr - 32'h1000;

  assign LED = {mem[4][0], mem[3][0], mem[2][0], mem[1][0], mem[0][0]};

  always @(posedge clk) begin
    if (reset) begin
      mem_ready <= 1'b0;
    end else if (mem_valid && !mem_ready) begin
      if (mem_we) begin
        mem[address] <= mem_wdata;
      end
      mem_rdata <= mem[address];
      mem_ready <= 1'b1;
    end else begin
      mem_ready <= 1'b0;
    end
  end


endmodule
