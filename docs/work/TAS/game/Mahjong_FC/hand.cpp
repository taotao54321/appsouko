#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

typedef unsigned long ulong;
typedef unsigned char byte;

namespace{
    const ulong RAND_INI[8] = { 0x0C000000, 0, 0, 0, 0, 0, 0, 0 };
    const int ITER = 33004;

    void error(const char* msg)
    {
        fputs(msg, stderr);
        putc('\n', stderr);
        exit(1);
    }

    int cmpbyte(const void* lhs, const void* rhs)
    {
        return *(byte*)lhs - *(byte*)rhs;
    }

    void shift(ulong r[8])
    {
        ulong c = ((r[0]&(1<<25))>>25)^((r[0]&(1<<17))>>17);
        for(int i = 0; i < 8; ++i){
            ulong c2 = r[i]&1;
            r[i] >>= 1;
            r[i] |= c<<31;
            c = c2;
        }
    }

    void expand_rand(const ulong rl[8], byte r[32])
    {
        for(int i = 0; i < 8; ++i)
            for(int j = 0; j < 4; ++j)
                r[4*i+j] = (rl[i]>>(24-8*j)) & 0xFF;
    }

    void modify_rand(byte r[32], byte X)
    {
        for(;;){
            byte A = r[5+X] & 0x3F;
            if(A==1 || A==0) r[5+X] |= 0x3F;
            A = r[2+X] = r[11+X] = r[5+X];
            if((A&0xC0) != 0xC0){
                --r[2+X];
                r[11+X] -= 2;
                return;
            }
            r[5+X] = r[30+X];
            r[30+X] >>= 1;
        }
    }

    byte routine_D367(byte X, byte r[32])
    {
        byte A, tmp;
        tmp = A = r[X] & 0xC0;
        byte foo = (A==0xC0 ? 8 : 10);
        byte bar = r[X] & 0x3F;
        if(!bar) bar = 2;

        byte Y = 0;
        do{
            ++Y;
            if(Y == foo) Y = 1;
        } while(--bar);

        return (tmp>>2) | Y;
    }

    byte routine_E508(byte n)
    {
        if(n == 1) return 0x37;
        else if((n-1)&0x0F) return n-1;
        else return (n-17)|0x09;
    }

    byte pick_pai(byte X, byte r[32], byte mem0400[0x100])
    {
        byte A = routine_D367(X, r);
        for(;;){
            X = A;
            if(mem0400[X]){
                --mem0400[X];
                return X;
            }
            A = routine_E508(X);
        }
    }

    void calc_hand(const ulong rl[8], byte hand[14], bool shuf2, bool dealer)
    {
        byte r[32];
        expand_rand(rl, r);

        modify_rand(r, 0);
        if(shuf2) modify_rand(r, 1);

        byte mem0400[0x100];
        memset(mem0400, 0, sizeof(mem0400));
        memset(mem0400+1, 4, 0x39);
        for(int i = dealer ? 14 : 13; i > 0; --i)
            hand[i-1] = pick_pai(i, r, mem0400);

        qsort(hand, 14, sizeof(byte), cmpbyte);
    }

    void show(const ulong r[8], const byte hand[14])
    {
        printf("%08lX%08lX%08lX%08lX%08lX%08lX%08lX%08lX\t"
               "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X\n",
               r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7],
               hand[0], hand[1], hand[2], hand[3], hand[4], hand[5], hand[6],
               hand[7], hand[8], hand[9], hand[10], hand[11], hand[12], hand[13]);
    }

    void enum_hand(bool shuf2, bool dealer)
    {
        ulong r[8];
        memcpy(r, RAND_INI, sizeof(r));

        for(int i = 0; i < ITER; ++i){
            byte hand[14];
            memset(hand, 0xFF, sizeof(hand));
            calc_hand(r, hand, shuf2, dealer);
            show(r, hand);
            shift(r);
        }
    }

    void usage()
    {
        error("Usage: hand <shuf2> <dealer>");
    }
}

int main(int argc, char** argv)
{
    if(argc != 3) usage();
    bool shuf2 = atoi(argv[1]);
    bool dealer = atoi(argv[2]);

    enum_hand(shuf2, dealer);

    return 0;
}
