module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/tb_fread.fst");
    $dumpvars(0, tb_fread);
end
endmodule
