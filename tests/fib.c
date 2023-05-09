int fibnumbers(int N) {
    int fib_0 = 0, fib_1 = 1;
    int fib = 0;
    for (int i = 1; i < N; i++) {
        fib_0 = fib_1;
        fib_1 = fib;
        fib = fib_0 + fib_1;
    }
    return fib;
}

int main() {
    int a = fibnumbers(6);
    asm("ecall\n");
    return a;
}