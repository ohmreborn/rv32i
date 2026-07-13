module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/SOC.fst");
    $dumpvars(0, SOC);
end
endmodule
