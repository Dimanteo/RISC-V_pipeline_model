.section .text
_start:
    la x1, Tgt
    jr x1
    addi x1, x0, 2
    addi x1, x0, 2
Tgt:
    ecall
