module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/memory.fst");
    $dumpvars(0, memory);
end
endmodule
