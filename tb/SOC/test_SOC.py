import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def mem_test(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ps").start())
    await RisingEdge(dut.clk)
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    for _ in range(4):
        for i in range(64):
            await RisingEdge(dut.clk)
