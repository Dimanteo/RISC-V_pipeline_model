int sum(int in) {
    if (in == 0) {
        return 0;
    }
    return in + sum(in - 1);
}

int main() {
    int ret = sum(10);
    asm("ecall\n");
    return ret;
}