all: simulate

NPROC = $$((`nproc`-1))

# -------------------------------------
# Testbench setup
# -------------------------------------
VERILATOR := verilator
ifdef VERILATOR_ROOT
VERILATOR := $(VERILATOR_ROOT)/bin/verilator
endif

UVM_ROOT ?=./home/mike/GitHubRepos/antmicro/verilator-verification-features-tests/main/uvm 
UVM_TEST ?= FIFO_memory_test

VERILOG_DEFINE_FILES = ${UVM_ROOT}/src/uvm.sv ./tb/FIFO_memory_top.sv ./tb/FIFO_memory.sv
VERILOG_INCLUDE_DIRS = tb ${UVM_ROOT}/src

# -------------------------------------
# Compilation/simulation configuration
# -------------------------------------
SIM_NAME ?= FIFO_memory_tb
SIM_DIR := ../$(SIM_NAME)-sim
COMPILE_ARGS += -fno-gate
COMPILE_ARGS += -DUVM_NO_DPI
COMPILE_ARGS += --prefix $(SIM_NAME) -o $(SIM_NAME)
COMPILE_ARGS += $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
EXTRA_ARGS += --timescale 1ns/1ps --error-limit 100
WARNING_ARGS += -Wno-lint \
	-Wno-style \
	-Wno-SYMRSVDWORD \
	-Wno-IGNOREDRETURN \
	-Wno-CONSTRAINTIGN \
	-Wno-ZERODLY

# -------------------------------------
# VCD Configuration
# -------------------------------------
VCD_VAR := +VCD_DUMP
VCD_FILE := dump.vcd

# -------------------------------------
# Make UVM test with Verilator
# -------------------------------------
$(SIM_DIR)/$(SIM_NAME).mk: $(wildcard tb/*.sv)
	$(VERILATOR) --cc --exe --main --timing --assert --trace-depth 2 -Mdir $(SIM_DIR) \
	--coverage \
	${COMPILE_ARGS} ${EXTRA_ARGS} \
	${VERILOG_DEFINE_FILES} \
	${WARNING_ARGS}

$(SIM_DIR)/$(SIM_NAME): $(SIM_DIR)/$(SIM_NAME).mk
	$(MAKE) -j${NPROC} -C $(SIM_DIR) $(BUILD_ARGS) -f $(SIM_NAME).mk

simulate: $(SIM_DIR)/$(SIM_NAME).mk $(SIM_DIR)/$(SIM_NAME)
	#$(SIM_DIR)/$(SIM_NAME) +UVM_TESTNAME=$(UVM_TEST) $(VCD_VAR) +VCD_FILE=$(VCD_FILE)
	$(SIM_DIR)/$(SIM_NAME) +UVM_TESTNAME=$(UVM_TEST)
	@echo "-- DONE --------------------"
view_vcd:
	gtkwave $(VCD_FILE)

clean:
	rm -rf simv*.daidir csrc
	rm -rf csrc* simv*
	rm -rf $(SIM_DIR)

.PHONY: simulate clean view_vcd
