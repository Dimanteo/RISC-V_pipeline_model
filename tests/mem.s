.section .text
_start:
    lw x1, 10(x0)
    lh x2, 10(x0)
    lb x3, 10(x0)
    addi x4, x0, 0
    sb x4, 0(x0)
    sh x4, 1(x0)
    sw x4, 3(x0)
    ecall