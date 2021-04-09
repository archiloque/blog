import strutils
import sequtils
import os
import re

let passwordRegex = re(r"^(\d+)-(\d+) ([a-z]{1}): ([a-z]+)$")

proc validPassword(line: string): bool =
  var matches: array[4, string]
  if line.match(passwordRegex, matches):
    let min = matches[0].parseInt()
    let max = matches[1].parseInt()
    let c = matches[2]
    let password = matches[3]
    let count = password.count(c)
    (count >= min) and (count <= max)
  else:
    raise newException(ValueError, "Can't parse [" & line & "]")

let count = readFile(paramStr(1)).splitLines().filter(validPassword).len()
echo(count)
