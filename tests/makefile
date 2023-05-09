all: genuimm.out alu.out mem.out jal.out jalr.out beq.out bne.out blt.out bge.out

%.out : %.s
	riscv32-unknown-elf-as $< -o $<.o
	riscv32-unknown-elf-ld $<.o -o $@

.PHONY: clean
clean:
	rm -f *.o *.out