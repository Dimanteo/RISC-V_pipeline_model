all: genuimm.out alu.out mem.out jal.out jalr.out beq.out bne.out blt.out bge.out fib.out recursive.out

%.out : %.s
	riscv32-unknown-elf-as $< -o $<.o
	riscv32-unknown-elf-ld $<.o -o $@

%.out : %.c
	riscv32-unknown-elf-gcc $< -O0 -nostdlib -emain -o $@

.PHONY: clean
clean:
	rm -f *.o *.out