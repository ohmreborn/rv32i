module memory #(
    parameter MemInit,
    parameter MEMSIZE = 1024  // 1024 words = 4KB of RAM
) (
    input wire clk,
    input wire reset,

    // CPU Bus Interface
    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [ 3:0] mem_wstrb,
    output reg  [31:0] mem_rdata,
    output reg         mem_ready,

    output wire [4:0] LED
);

  reg  [ 1:0] state;

  wire        Isperipheral;
  wire [31:0] bram_addr;
  wire [ 7:0] bram_wdata;
  wire        bram_we;
  wire        bram_valid;
  wire [ 7:0] bram_rdata;
  wire        bram_ready;

  assign Isperipheral = ((mem_addr == 32'h1000) || (mem_addr == 32'h1004));
  assign bram_addr = mem_addr + state;
  assign bram_wdata = mem_wdata[state*8+:8];
  assign bram_we = mem_wstrb[state] && !Isperipheral;
  assign bram_valid = mem_valid && !Isperipheral;

  wire [31:0] peripheral_addr;
  wire [ 7:0] peripheral_wdata;
  wire        peripheral_we;
  wire        peripheral_valid;
  wire [ 7:0] peripheral_rdata;
  wire        peripheral_ready;


  assign peripheral_addr = mem_addr + state;
  assign peripheral_wdata = mem_wdata[state*8+:8];
  assign peripheral_we = mem_wstrb[state] & Isperipheral;
  assign peripheral_valid = mem_valid & Isperipheral;

  wire ready;
  wire valid;
  assign ready = Isperipheral ? peripheral_ready : bram_ready;
  assign valid = Isperipheral ? peripheral_valid : bram_valid;

  bram #(
      .MemInit(MemInit),
      .MEMSIZE(MEMSIZE * 4)
  ) mybram (
      .clk  (clk),
      .reset(reset),

      .mem_valid(bram_valid),
      .mem_addr(bram_addr),
      .mem_wdata(bram_wdata),
      .mem_we(bram_we),
      .mem_rdata(bram_rdata),
      .mem_ready(bram_ready)
  );


  peripheral myLED (
      .clk  (clk),
      .reset(reset),

      .mem_valid(peripheral_valid),
      .mem_addr(peripheral_addr),
      .mem_wdata(peripheral_wdata),
      .mem_we(peripheral_we),
      .mem_rdata(peripheral_rdata),
      .mem_ready(peripheral_ready),
      .LED(LED)
  );

  always @(posedge clk) begin
    if (reset) begin
      state     <= 2'b00;
      mem_ready <= 1'b0;
      mem_rdata <= 32'b0;
    end else begin
      if (valid) begin
          if (ready) begin
            mem_rdata[state*8+:8] <= Isperipheral ? peripheral_rdata : bram_rdata;
            if (state == 2'b11) begin
              state     <= 2'b00;
              mem_ready <= 1'b1;
            end else begin
              state <= state + 1'b1;
            end
          end
          else begin
              mem_ready <= 1'b0;
              state <= state;
          end
      end
      else begin
          mem_ready <= 1'b0;
          state <= 2'b0;
      end
    end
  end

endmodule
