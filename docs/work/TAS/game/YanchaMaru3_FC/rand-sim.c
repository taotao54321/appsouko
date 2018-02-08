#include <stdio.h>

static unsigned char mem[0x0800];

static void ADC(unsigned char* lhs, unsigned char rhs, int* carry)
{
    unsigned int tmp;

    tmp = *lhs + rhs + (*carry ? 1 : 0);
    *lhs = tmp & 0xFF;
    *carry = (tmp > 0xFF) ? 1 : 0;
}

static void ROL(unsigned char* value, int* carry)
{
    int carry_next;

    carry_next = (*value & 0x80) ? 1 : 0;
    *value <<= 1;
    if(*carry) { *value |= 0x01; }
    *carry = carry_next;
}

static void init()
{
    mem[0x0047] = 0x00;
    mem[0x0689] = 0x55;
    mem[0x068A] = 0x00;
}

static void update_mem()
{
    unsigned char A, Y;
    int carry = 0;

    ++mem[0x0047];

    A = mem[0x068A] & 0x07;
    Y = A;

    do{
        ROL(&mem[0x0689], &carry);
        ROL(&mem[0x068A], &carry);
        --Y;
    } while(!(Y & 0x80));

    ADC(&mem[0x0689], mem[0x0047] & 0x04, &carry);
    ADC(&mem[0x068A], 0, &carry);
    /* A = mem[0x068A]; */
}

static void print_mem(int af)
{
    printf("%d\t%u\t%u\t%u\n", af, mem[0x0047], mem[0x0689], mem[0x068A]);
}

int main(int argc, char** argv)
{
    int af;

    init();

    for(af = 0; af < 2050; ++af){
        print_mem(af);
        update_mem();
    }

    return 0;
}
