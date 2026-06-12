module memory #(
    parameter MemInit = "../firmware/build/blink.hex",
    parameter MEMSIZE = 64
) (
    input wire clk,
    input wire reset,
    // read memory
    input wire [31:0] read_address,
    output reg [31:0] read_data,
    output reg read_bussy,
    // write memory
    input wire [31:0] write_address,
    input wire [31:0] write_data,
    input wire write_enable,
    output reg write_bussy
);
    reg [31:0] main_memory[0:MEMSIZE-1];
    initial begin
        $readmemh(MemInit, main_memory);
    end

    reg state;
    always @(posedge clk) begin
        if (reset) begin
            state <= 2'b00;
        end
        else begin
            case (state)
                1'b0: begin
                    read_data <= main_memory[read_address[7:2]];
                    read_bussy <= 1'b1;
                    state <= 1'b1;
                end
                1'b1: begin
                    read_bussy <= 1'b0;
                    state <= 1'b0;
                end
            endcase
        end

    end
endmodule
