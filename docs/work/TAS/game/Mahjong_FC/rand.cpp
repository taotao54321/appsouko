#include <cstdio>
#include <cstdlib>

using namespace std;

typedef unsigned long ulong;

namespace{
    void error(const char* msg)
    {
        fputs(msg, stderr);
        putc('\n', stderr);
        exit(1);
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

    void show(const ulong r[8])
    {
        printf("%08lX%08lX%08lX%08lX%08lX%08lX%08lX%08lX\n",
               r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7]);
    }

    void usage()
    {
        error("Usage: rand <iter>");
    }
}

int main(int argc, char** argv)
{
    if(argc != 2) usage();
    int n = atoi(argv[1]);

    ulong r[8] = { 0x0C000000, 0, 0, 0, 0, 0, 0, 0 };
    for(int i = 0; i < n; ++i){
        show(r);
        shift(r);
    }

    return 0;
}
