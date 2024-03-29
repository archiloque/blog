import strutils
import os
import re
import sets

const NOP_OPERATION = "nop"
const JUMP_OPERATION = "jmp"
const ACC_OPERATION = "acc"
const OPERATIONS = [NOP_OPERATION, JUMP_OPERATION, ACC_OPERATION]
let instructionRegex = re(r"^(" & OPERATIONS.join("|") & r") ([+-]{1}\d+)$")

type
  Instruction = ref object
    operation: string
    operand: int

let input: seq[string] = readFile(paramStr(1)).splitLines()
var program: seq[Instruction] = @[]

for line in input:
  var instructionMatch: array[2, string]
  if line.match(instructionRegex, instructionMatch):
    let instruction: Instruction = Instruction(operation: instructionMatch[0],
        operand: instructionMatch[1].parseInt())
    program.add(instruction)
  else:
    raise newException(ValueError, "Can't parse [" & line & "]")

var currentInstructionIndex: int = 0
var accumulator: int = 0
var exploredInstructions: HashSet[int] = initHashSet[int]()

while true:
  exploredInstructions.incl(currentInstructionIndex)
  let currentInstruction = program[currentInstructionIndex]
  case currentInstruction.operation:
    of NOP_OPERATION:
      currentInstructionIndex += 1
    of JUMP_OPERATION:
      currentInstructionIndex += currentInstruction.operand
    of ACC_OPERATION:
      accumulator += currentInstruction.operand
      currentInstructionIndex += 1
    else:
      raise newException(ValueError, "Unknown operation [" &
          currentInstruction.operation & "]")
  if exploredInstructions.contains(currentInstructionIndex):
    echo(accumulator)
    quit()
