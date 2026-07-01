module memory #(
    parameter MemInit = "../firmware/build/load.hex",
    parameter integer MEMSIZE = 4096
) (
    input wire clk,

    // CPU Bus Interface
    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [ 3:0] mem_wstrb,
    output reg  [31:0] mem_rdata,
    output reg         mem_ready,

    output wire [4:0] LED
);

    reg  [ 7:0] mem                  [0:MEMSIZE-1];
    reg [1:0] state;

    reg [7:0] LED_MAP[0:3];
    assign LED = LED_MAP[0][4:0];

    initial begin
        $readmemh(MemInit, mem);
    end

    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            if (mem_wstrb[state]) begin
                if (mem_addr == 32'h1000) begin
                    LED_MAP[mem_addr+state] <= mem_wdata;
                end
                else begin
                    mem[mem_addr+state] <= mem_wdata;
                end
            end
            case (state)
                2'b00: begin
                    mem_rdata[7:0] <= (mem_addr == 32'h1000) ? LED_MAP[mem_addr+state] : mem[mem_addr+state];
                    mem_ready <= 1'b0;
                    state <= 2'b01;
                end
                2'b01: begin
                    mem_rdata[15:8] <= (mem_addr == 32'h1000) ? LED_MAP[mem_addr+state] : mem[mem_addr+state];
                    mem_ready <= 1'b0;
                    state <= 2'b10;
                end
                2'b10: begin
                    mem_rdata[23:16] <= (mem_addr == 32'h1000) ? LED_MAP[mem_addr+state] : mem[mem_addr+state];
                    mem_ready <= 1'b0;
                    state <= 2'b11;
                end
                2'b11: begin
                    mem_rdata[31:24] <= (mem_addr == 32'h1000) ? LED_MAP[mem_addr+state] : mem[mem_addr+state];
                    mem_ready <= 1'b1;
                    state <= 2'b00;
                end
            endcase
        end else begin
            mem_ready <= 1'b0;
            state <= 2'b0;
        end
    end


endmodule
