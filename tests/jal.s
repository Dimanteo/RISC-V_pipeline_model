.section .text
_start:
    addi x1, x0, 2
    j Tgt
    addi x1, x0, 2
    addi x1, x0, 2
Tgt:
    ecall
