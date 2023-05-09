.section .text
_start:
    addi x3, x0, 0
    addi x1, x0, 5
    addi x2, x0, 6
    bge x1, x2, .Finish
    addi x3, x0, 1
    addi x2, x0, 5
    bge x1, x2, .Finish
    addi x3, x0, 2
    .Finish:
    ecall
