#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 注意: OPデモの文字列はコード体系が異なる

import sys
from StringIO import StringIO
import codecs, locale

DM_CHAR = tuple(map(lambda c: None if c=="." else c, u"""\
0123456789・!?「－ホ\
あいうえおかきくけこさしすせそた\
ちつてとなにぬねのはひふへほまみ\
むめもやゆよらりるれろわをんゃゅ\
ょっ゛〟。アイウエオカキクコサシ\
スセソタツテトナニワハヒフチマミ\
ムメモヤユラョルレロンャュァィケ\
ェォッHMPE........ \
がぎぐげござじずぜぞだぢづでどば\
びぶべぼぱぴぷ.ぽガギグゴザジズ\
ゼゾダ.デドバビブボパピプポヴゲ\
ペ...............\
............主...\
................\
................\
............/▽問□\
"""
))

STR_LEN_MIN = 3

ENC_LOCALE = locale.getpreferredencoding()
sys.stdout = codecs.getwriter(ENC_LOCALE)(sys.stdout, errors='replace')
sys.stderr = codecs.getwriter(ENC_LOCALE)(sys.stderr, errors='replace')

write = sys.stdout.write

def bytes(inp):
    while True:
        c = inp.read(1)
        if not c: return
        yield ord(c)

def error(msg):
    sys.exit(msg)

def strings(inp):
    addr = 0
    s = StringIO()
    in_str = False
    for i, b in enumerate(bytes(inp)):
        if DM_CHAR[b]:
            if not in_str:
                addr = i
            in_str = True
            s.write(DM_CHAR[b])
        else:
            if in_str:
                in_str = False
                if len(s.getvalue()) >= STR_LEN_MIN: yield addr, s.getvalue()
                s = StringIO()
    if len(s.getvalue()) >= STR_LEN_MIN: yield addr, s.getvalue()

def usage():
    error("Usage: strings <file>")

def main():
    if len(sys.argv) != 2: usage()
    inp = open(sys.argv[1], 'rb')
    for addr, s in strings(inp):
        write("0x%06X\t%s\n" % (addr, s))
    inp.close()

if __name__ == "__main__": main()
