/**
 * シーザースパレス(GB) リール値計算
 */

#include <cstdio>

using namespace std;

typedef unsigned char uchar;
typedef unsigned int uint;

namespace{
    const int REEL_NUM = 22;

    const uchar DATA_42E0[0x40] = {
        0x00,
        0x01, 0x01, 0x01, 0x01,
        0x02, 0x02,
        0x03, 0x03, 0x03, 0x03,
        0x04, 0x04,
        0x05, 0x05, 0x05, 0x05,
        0x06, 0x06,
        0x07, 0x07, 0x07, 0x07,
        0x08, 0x08,
        0x09, 0x09, 0x09, 0x09,
        0x0A, 0x0A,
        0x0B, 0x0B, 0x0B, 0x0B,
        0x0C, 0x0C,
        0x0D, 0x0D, 0x0D, 0x0D,
        0x0E, 0x0E,
        0x0F, 0x0F, 0x0F, 0x0F,
        0x10, 0x10,
        0x11, 0x11, 0x11, 0x11,
        0x12, 0x12,
        0x13, 0x13, 0x13, 0x13,
        0x14, 0x14,
        0x15, 0x15, 0x15
    };
    const uchar DATA_4320[0x40] = {
        0x00,
        0x01, 0x01, 0x01, 0x01,
        0x02, 0x02, 0x02,
        0x03, 0x03, 0x03,
        0x04, 0x04,
        0x05, 0x05, 0x05, 0x05,
        0x06, 0x06,
        0x07, 0x07, 0x07, 0x07,
        0x08, 0x08,
        0x09, 0x09, 0x09, 0x09,
        0x0A, 0x0A,
        0x0B, 0x0B, 0x0B, 0x0B,
        0x0C, 0x0C,
        0x0D, 0x0D, 0x0D, 0x0D,
        0x0E, 0x0E,
        0x0F, 0x0F, 0x0F, 0x0F,
        0x10, 0x10,
        0x11, 0x11, 0x11, 0x11,
        0x12, 0x12,
        0x13, 0x13, 0x13, 0x13,
        0x14, 0x14,
        0x15, 0x15, 0x15
    };

    typedef uint (*ReelFunc)(uint r);

    uint reel0(uint r)
    {
        uint offset = (0x40*r)>>8;
        return (DATA_42E0[offset]+0x12) % REEL_NUM;
    }

    uint reel1(uint r)
    {
        uint offset = (0x40*r)>>8;
        return (DATA_4320[offset]+0x0A) % REEL_NUM;
    }

    uint reel2(uint r)
    {
        uint offset = (0x40*r)>>8;
        return (DATA_4320[offset]+0x02) % REEL_NUM;
    }

    uint reel3(uint r)
    {
        uint offset = (0x40*r)>>8;
        return (DATA_42E0[offset]+0x10) % REEL_NUM;
    }
}

int main(int argc, char** argv)
{
    const ReelFunc rf[4] = { reel0, reel1, reel2, reel3 };

    for(uint r = 0; r <= 0xFF; ++r){
        uint reel[4];
        for(int i = 0; i < 4; ++i) reel[i] = rf[i](r);
        printf("0x%02X\t0x%02X\t0x%02X\t0x%02X\t0x%02X\n",
               r, reel[0], reel[1], reel[2], reel[3]);
    }

    return 0;
}
