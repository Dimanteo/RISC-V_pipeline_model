.section .text
_start:
    addi x1, x0, 5
    lb x2, 5(x1)
    addi x3, x2, 0
    ecall
