.section .text
_start:
    addi x1, x0, 2
    j Tgt
    addi x2, x0, 1
    addi x2, x2, 1
    addi x2, x0, 1
    addi x2, x2, 1
Tgt:
    ecall
