module tb_fread(
    input wire clk,
    input wire [31:0] address,
    output reg [31:0] data_out 
);
    integer file_id;
    reg [31:0] data_in;
    reg [31:0] memory [0:255];
    integer i;

    initial begin
        file_id = $fopen("/Users/krittiwitkampradam/Documents/myrisc-v-101/multi-cycle/firmware/build/blink.bin", "rb");
        i = 0;
        while (!$feof(file_id)) begin
            $fread(data_in, file_id);
            memory[i] = data_in;
            i = i+1;
        end
        $fclose(file_id);
    end

    always @(posedge clk) begin
        data_out <= memory[address];
    end
endmodule
