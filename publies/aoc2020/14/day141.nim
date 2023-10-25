import strutils
import os
import tables
import re

const MEMORY_SIZE = 36
let MASK_INSTRUCTION_REGEX = re(r"^mask = ([X01]{" & $MEMORY_SIZE & r"})$")
let WRITE_INSTRUCTION_REGEX = re(r"^mem\[(\d+)\] = (\d+)$")

let program: seq[string] = readFile(paramStr(1)).splitLines()

var memory = initTable[int, BiggestInt]()
var currentMask: string = ""

for line in program:
  var maskMatch: array[1, string]
  if line.match(MASK_INSTRUCTION_REGEX, maskMatch):
    currentMask = maskMatch[0]
    discard
  else:
    var writeMatch: array[2, string]
    if line.match(WRITE_INSTRUCTION_REGEX, writeMatch):
      let valueParameter = writeMatch[1].parseInt().toBin(MEMORY_SIZE)
      var result: string = `'0`'.repeat(MEMORY_SIZE)
      for i in countup(0, MEMORY_SIZE - 1):
        case currentMask[i]:
        of `'0`':
          result[i] = `'0`'
        of `'1`':
          result[i] = `'1`'
        of `'X`':
          result[i] = valueParameter[i]
        else:
          raise newException(ValueError, "Unknown action [" & currentMask[i] & "]")
      let resultAsInteger = fromBin[BiggestInt](result)
      memory[writeMatch[0].parseInt()] = resultAsInteger
    else:
      raise newException(ValueError, "Can`'t parse [" & line & "]")
echo(memory)

var sum: BiggestInt = 0
for address, value in memory:
  sum += value
echo(sum)
