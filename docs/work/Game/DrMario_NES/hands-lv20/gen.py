#!/usr/bin/env python3
# -*- coding: utf-8 -*-



def main():
    print('<table border="1">')

    for r in range(80):
        print("  <tr>")
        for c in range(10):
            n = 10*r + c + 1
            print(f"    <td>{n:03d}</td>")
        print("  </tr>")
        print("  <tr>")
        for c in range(10):
            n = 10*r + c + 1
            print(f'    <td><a href="{n:03d}.txt"><img src="{n:03d}.png"></a></td>')
        print("  </tr>")

    print("</table>")

if __name__ == "__main__": main()
