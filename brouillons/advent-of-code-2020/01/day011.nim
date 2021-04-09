import strutils
import sequtils
import os

let input: seq[int] = readFile(paramStr(1)).splitLines().map(parseInt)

for i, first in input:
  for second in input[i + 1 .. ^1]:
    if first + second == 2020:
      echo(first, " ", second, " ", (first * second))
      quit()
