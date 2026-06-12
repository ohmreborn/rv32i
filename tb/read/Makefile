# defaults
SIM ?= icarus 
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../../src/read.v
VERILOG_SOURCES += $(PWD)/../../src/decode.v
WAVES = 1

# use VHDL_SOURCES for VHDL files

# COCOTB_TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
COCOTB_TOPLEVEL = tb_fread

# COCOTB_TEST_MODULES is the basename of the Python test file(s)
COCOTB_TEST_MODULES = test_read

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
