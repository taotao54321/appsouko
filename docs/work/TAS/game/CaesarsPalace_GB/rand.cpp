/**
 * シーザースパレス(GB) 乱数値調査
 */

#include <cstdio>

using namespace std;

typedef unsigned int uint;

namespace{
    void ADC8(uint& lhs, uint rhs, bool& carry)
    {
        uint tmp;
        tmp = lhs + rhs + (carry?1:0);
        lhs = tmp & 0xFF;
        carry = tmp > 0xFF;
    }

    void SLA(uint& n, bool& carry)
    {
        carry = n & 0x80;
        n <<= 1;
        n &= 0xFF;
    }

    uint suzy_rand(uint f)
    {
        uint r = f;
        bool carry = false;

        r ^= 0x55;
        SLA(r, carry);
        ADC8(r, 0x0D, carry);
        r ^= 0xE9;
        SLA(r, carry);
        ADC8(r, 0x13, carry);
        r ^= 0x22;
        SLA(r, carry);
        ADC8(r, 0x17, carry);

        return r;
    }
}

int main(int argc, char** argv)
{
    for(uint f = 0; f <= 0xFF; ++f)
        printf("0x%02X\t0x%02X\n", f, suzy_rand(f));

    return 0;
}
