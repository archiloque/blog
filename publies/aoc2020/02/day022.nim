import strutils
import sequtils
import os
import re

let passwordRegex = re(r"^(\d+)-(\d+) ([a-z]{1}): ([a-z]+)$")

proc validPassword(line: string): bool =
  var matches: array[4, string]
  if line.match(passwordRegex, matches):
    let first = matches[0].parseInt()
    let second = matches[1].parseInt()
    let c = matches[2][0]
    let password = matches[3]
    ((password[first - 1] == c) and (password[second - 1] != c)) or ((password[
        first - 1] != c) and (password[second - 1] == c))
  else:
    raise newException(ValueError, "Can`'t parse [" & line & "]")

let count = readFile(paramStr(1)).splitLines().filter(validPassword).len()
echo(count)
