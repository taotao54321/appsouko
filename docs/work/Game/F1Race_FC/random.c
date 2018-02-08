#include <stdio.h>

#define PERIOD 0xFFFE

static unsigned int shift(unsigned int v)
{
    unsigned int bit_new;

    bit_new = ~((v>>15) ^ (v>>1) ^ (v>>0)) & 0x0001;

    return ((v<<1) | bit_new) & 0xFFFF;
}

int main(int argc, char** argv)
{
    unsigned int v;
    unsigned int e_95, e_gen_fast, e_gen_slow;
    unsigned long i;

    v = 0x0000;
    for(i = 0; i < PERIOD; ++i){
        e_95 = (v&0x000F)>>1;
        e_gen_fast = ((v&0x001F) ? 0 : 1);
        e_gen_slow = ((v&0x01FF) ? 0 : 1);
        printf("0x%04X\t%u\t%u\t%u\n", v, e_95, e_gen_fast, e_gen_slow);
        v = shift(v);
    }

    return 0;
}
