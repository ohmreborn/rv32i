module memory #(
    parameter string MemInit = "MachineCode.mem",
    parameter int MEMSIZE = 64
) (
    input wire clk,
    // read memory
    input wire [63:0] read_address,
    output reg [31:0] read_data,
    output reg read_bussy,
    // write memory
    input wire [63:0] write_address,
    input wire [31:0] write_data,
    input wire write_enable,
    output reg write_bussy
);
  initial begin
    if (MemInit != "") begin
      $display("Loading Machine Code.");
      $readmemb(MemInit, main_memory);
    end
  end

  reg [31:0] main_memory[MEMSIZE];
  reg [31:0] prev_read_address;
  always_comb begin
    if (prev_read_address != read_address) begin
      read_bussy = 1;
    end
  end
  always_ff @(posedge clk) begin
    prev_read_address <= read_address;
    read_bussy <= 0;
    case (read_address[1:0])
      (00): begin
        read_data[31:0] <= main_memory[read_address[31:2]];  // 4 byte
      end
      (01): begin
        read_data[31:8] <= main_memory[read_address[31:2]][31:8];  // 3 byte
      end
      (10): begin
        read_data[31:16] <= main_memory[read_address[31:2]][31:16];  // 2 byte
      end
      (11): begin
        read_data[31:24] <= main_memory[read_address[31:2]][31:24];  // 1 byte
      end
      default: ;
    endcase
  end
endmodule
