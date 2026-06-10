import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def memory_test(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ps").start())
    await RisingEdge(dut.clk)
    a = 0
    for i in range(10):
        if (dut.read_bussy.value != 1):
            dut.read_address.value = a
            a += 1
        await RisingEdge(dut.clk)
