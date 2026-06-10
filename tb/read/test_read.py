import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def mem_test(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ps").start())
    await RisingEdge(dut.clk)
    dut.address.value = 0
    await RisingEdge(dut.clk)
    dut.address.value = 1
    await RisingEdge(dut.clk)
    dut.address.value = 2 
    await RisingEdge(dut.clk)
    dut.address.value = 3
