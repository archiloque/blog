import strutils
import sequtils
import os

let input: seq[int] = readFile(paramStr(1)).splitLines().map(parseInt)

for i, first in input:
  for j, second in input[i + 1 .. ^1]:
    for third in input[j + 1 .. ^1]:
      if first + second + third == 2020:
        echo(first, " ", second, " ", third, " ", (first * second * third))
        quit()
