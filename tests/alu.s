_start:
    addi x1, x0, 5
    addi x2, x0, 2
    sub x3, x1, x2
    slt x4, x1, x2
    slt x5, x2, x1
    or x6, x1, x2
    xor x7, x1, x2
    xor x8, x1, x1
    sll x9, x1, x2
    sra x10, x1, x2
    srl x11, x1, x2
    ecall
