# SOURCES := src/alu/eight_bit_adder.v \
# 	   src/alu/eight_bit_subtractor.v \
#            src/alu/four_bit_adder.v \
#            src/alu/full_adder.v \
#            src/alu/half_adder.v \
# 	   src/alu/equal_to.v \
# 	   src/alu/less_than.v \
# 	   src/alu/shifter.v \
# 	   src/alu/alu.v \
# 	   src/alu/four_bit_mux.v \
# 	   src/alu/alu_dataflow.v

SOURCES := src/registers/register_bank.v

TESTBENCH := sim/tb_reg_bank.cpp
TOP_MODULE := register_bank

INCLUDES :=

VERILATOR_FLAGS = -Wall --cc --trace -j 1 --exe
BUILD_DIR = ./
OBJ_DIR = $(BUILD_DIR)/obj_dir
EXE = $(OBJ_DIR)/V$(TOP_MODULE)

### Targets

all: sim

sim:
	@echo "Building for Simulation..."
	verilator $(VERILATOR_FLAGS) --top-module $(TOP_MODULE) \
		--Mdir $(OBJ_DIR) $(TESTBENCH) $(SOURCES)
	make -C $(OBJ_DIR) -f V$(TOP_MODULE).mk V$(TOP_MODULE)
	@echo "Running the simulation..."
	$(EXE)

view:
	gtkwave $(BUILD_DIR)/*.vcd &

clean:
	rm -rf $(OBJ_DIR) *.vcd *.log

circ:
	yosys -p "read -sv $(SOURCES); hierarchy -top $(TOP_MODULE); synth -top $(TOP_MODULE); show -format png -prefix alu_diagram $(TOP_MODULE);"
	sxiv ./

.PHONY: all sim view clean
