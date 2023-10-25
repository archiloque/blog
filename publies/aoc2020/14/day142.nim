import strutils
import os
import tables
import re

const MEMORY_SIZE = 36
let MASK_INSTRUCTION_REGEX = re(r"^mask = ([X01]{" & $MEMORY_SIZE & r"})$")
let WRITE_INSTRUCTION_REGEX = re(r"^mem\[(\d+)\] = (\d+)$")

let program: seq[string] = readFile(paramStr(1)).splitLines()

var memory = newTable[BiggestInt, BiggestInt]()
var currentMask: string = ""

proc processWrite(memoryAddress: string, value: BiggestInt, memory: ref Table[
    BiggestInt, BiggestInt]) =
  let xIndex = memoryAddress.find(`'X`')
  if xIndex == -1:
    let memoryAddressAsInteger: BiggestInt = fromBin[BiggestInt](memoryAddress)
    memory[memoryAddressAsInteger] = value
  else:
    var memoryAddress0 = memoryAddress
    memoryAddress0[xIndex] = `'0`'
    processWrite(memoryAddress0, value, memory)
    var memoryAddress1 = memoryAddress
    memoryAddress1[xIndex] = `'1`'
    processWrite(memoryAddress1, value, memory)

for line in program:
  var maskMatch: array[1, string]
  if line.match(MASK_INSTRUCTION_REGEX, maskMatch):
    currentMask = maskMatch[0]
    discard
  else:
    var writeMatch: array[2, string]
    if line.match(WRITE_INSTRUCTION_REGEX, writeMatch):
      let memoryAddress = writeMatch[0].parseInt().toBin(MEMORY_SIZE)
      var result: string = `'0`'.repeat(MEMORY_SIZE)
      for i in countup(0, MEMORY_SIZE - 1):
        case currentMask[i]:
        of `'0`':
          result[i] = memoryAddress[i]
        of `'1`':
          result[i] = `'1`'
        of `'X`':
          result[i] = `'X`'
        else:
          raise newException(ValueError, "Unknown action [" & currentMask[i] & "]")
      let valueToWrite = writeMatch[1].parseBiggestInt()
      processWrite(result, valueToWrite, memory)
    else:
      raise newException(ValueError, "Can`'t parse [" & line & "]")

echo(memory)

var sum: BiggestInt = 0
for address, value in memory:
  sum += value
echo(sum)
