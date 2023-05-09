.section .text
_start:
    addi x3, x0, 0
    addi x1, x0, 12
    addi x2, x0, 12
    bne x1, x2, .Tgt1
    addi x3, x3, 1
    .Tgt1:
    addi x1, x0, 10
    addi x2, x0, 12
    bne x1, x2, .Tgt2
    addi x3, x3, 2
    .Tgt2:
    ecall
