/**
 * Wizardry (NES) ボーナスポイント総当たり調査
 *
 * $40, $41 はこれより前でも変更されるので、前フレームの乱数値を基準とした調
 * 査ではないことに注意。
 */

#include <stdio.h>

static unsigned char A, Y;
static unsigned char mem[0x0800];

static void ADC(unsigned char* lhs, unsigned char rhs, int* carry)
{
    unsigned int tmp;

    tmp = *lhs + rhs + (*carry ? 1 : 0);
    *lhs = tmp & 0xFF;
    *carry = (tmp > 0xFF) ? 1 : 0;
}

static void ASL(unsigned char* value, int* carry)
{
    *carry = (*value & 0x80) ? 1 : 0;
    *value <<= 1;
}

static void ROL(unsigned char* value, int* carry)
{
    int carry_next;

    carry_next = (*value & 0x80) ? 1 : 0;
    *value <<= 1;
    if(*carry) { *value |= 0x01; }
    *carry = carry_next;
}

static void routine_C2A9()
{
    mem[0x41] += mem[0x40];
    if(!++mem[0x40]) ++mem[0x41];
    A = mem[0x41];
}

static void routine_CD4B()
{
    int carry = 0;

    mem[0x04] = A;
    mem[0x06] = mem[0x40];
    mem[0x05] = mem[0x00];

    A = 0x00;
    Y = 0x10;

    do{
        ASL(&A, &carry);
        ROL(&mem[0x06], &carry);
        ROL(&mem[0x04], &carry);
        if(!carry) continue;

        carry = 0;
        ADC(&A, mem[0x05], &carry);
        if(!carry) continue;

        ++mem[0x06];
    } while(--Y);

    mem[0x05] = A;
    A = mem[0x04];
}

static void routine_CD3C()
{
    mem[0x00] = A;
    mem[0x03] = Y;

    routine_C2A9();
    routine_CD4B();

    Y = mem[0x03];
#if 0
    A = mem[0x04]; /* ルーチン $CD4B 内で既に行われているので不要なはず */
#endif
}

int main(int argc, char** argv)
{
#if 1
    unsigned int r, i;

    printf("# r\t$025B\t$04\t$05\t$06\n");

    for(r = 0; r <= 0xFFFF; ++r){
        mem[0x40] = r & 0xFF;
        mem[0x41] = r >> 8;

        A = 5;
        routine_CD3C();
        mem[0x025B] = A + 5;

        for(i = 0; i < 2; ++i){
            routine_C2A9();
            if(A < 0x0D) mem[0x025B] += 10;
        }

        printf("0x%04X\t%02X\t%02X\t%02X\t%02X\n",
               r, mem[0x025B], mem[0x04], mem[0x05], mem[0x06]);
    }
#endif

#if 0
    unsigned int r;

    r = 0x9C3C;
    mem[0x40] = r & 0xFF;
    mem[0x41] = r >> 8;
    A = 5;
    routine_CD3C();
    mem[0x025B] = A + 5;

    printf("0x%04X\t0x%02X\n", r, A);
#endif

    return 0;
}
