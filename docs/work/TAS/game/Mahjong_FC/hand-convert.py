#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

def nsplit(seq, n):
    i = 0
    while i < len(seq):
        yield seq[i:i+n]
        i += n

write = sys.stdout.write

def error(msg):
    sys.exit(msg)

def conv(n):
    if n == 0xFF: return None
    elif 0x31 <= n <= 0x34: return n-0x30+0x40
    elif 0x35 <= n <= 0x37: return n-0x34+0x80
    else: return n

def main():
    for line in sys.stdin:
        line = line.strip()
        if not len(line): continue
        if line.startswith("#"): continue
        if len(line) != 14*2: error("Not 14 pais")
        pais = map(lambda s: int(s, 16), nsplit(line, 2))
        pais_conv = filter(None, map(conv, pais))
        for pai in pais_conv:
            write("%02X" % pai)
        write("\n")

if __name__ == "__main__": main()
