.section .text
_start:
    la x1, Tgt
    jr x1
    addi x2, x0, 1
    addi x2, x2, 1
    addi x2, x2, 1
    addi x2, x2, 1
    addi x2, x2, 1
Tgt:
    ecall
