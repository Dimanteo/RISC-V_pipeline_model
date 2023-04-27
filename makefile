TOP_MODULE = top
SRC = main.cpp
VERILATOR = verilator
VERILATOR_FLAGS = -cc --exe

all: compile

compile : verilate
	make -j -C obj_dir/ -f V$(TOP_MODULE).mk

verilate : $(TOP_MODULE).v $(SRC)
	$(VERILATOR) $(VERILATOR_FLAGS) $^