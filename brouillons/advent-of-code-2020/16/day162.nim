import strutils
import os
import tables
import re
import sequtils
import sets

var setup: seq[string] = readFile(paramStr(1)).splitLines()

let ruleRegex = re(r"^([^:]+): (\d+)-(\d+) or (\d+)-(\d+)$")

var validValuesAnyField = initHashSet[int]()
var validValuesPerField = initTable[string, HashSet[int]]()

var currentLineIndex = 0
var fieldsNames: seq[string] = @[]
var ruleMatch: array[5, string]

while setup[currentLineIndex].match(ruleRegex, ruleMatch):
  let fieldName = ruleMatch[0]
  fieldsNames.add(fieldName)
  var validValuesCurrentField = initHashSet[int]()
  for i in countup(ruleMatch[1].parseInt(), ruleMatch[2].parseInt()):
    validValuesAnyField.incl(i)
    validValuesCurrentField.incl(i)
  for i in countup(ruleMatch[3].parseInt(), ruleMatch[4].parseInt()):
    validValuesAnyField.incl(i)
    validValuesCurrentField.incl(i)
  validValuesPerField[fieldName] = validValuesCurrentField
  currentLineIndex += 1

var possibleFieldsPerIndex: Table[int, seq[string]] = initTable[int, seq[string]]()
for i in countup(0, validValuesPerField.len() - 1):
  possibleFieldsPerIndex[i] = fieldsNames

while setup[currentLineIndex] != "your ticket:":
  currentLineIndex += 1
currentLineIndex += 1
let myTickets = setup[currentLineIndex].split(",").map(parseInt)

while setup[currentLineIndex] != "nearby tickets:":
  currentLineIndex += 1
currentLineIndex += 1

var validTickets: seq[seq[int]] = @[]

while currentLineIndex < setup.len():
  let currentTicket = setup[currentLineIndex].split(",").map(parseInt)
  if currentTicket.all(proc (v: int): bool = validValuesAnyField.contains(v)):
    validTickets.add(currentTicket)
  currentLineIndex += 1

for validTicket in validTickets:
  for index, value in validTicket:
    var possibleFields = possibleFieldsPerIndex[index]
    possibleFields.keepIf(proc(fieldName: string): bool = validValuesPerField[
        fieldName].contains(value))
    possibleFieldsPerIndex[index] = possibleFields

var fieldNames: Table[int, string] = initTable[int, string]()

while(possibleFieldsPerIndex.len() > 0):
  for fieldIndex, fieldPossibleNames in possibleFieldsPerIndex:
    if fieldPossibleNames.len() == 1:
      let fieldName = fieldPossibleNames[0]
      fieldNames[fieldIndex] = fieldName
      possibleFieldsPerIndex.del(fieldIndex)
      for i, f in possibleFieldsPerIndex:
        var names = f
        names.keepItIf(it != fieldName)
        possibleFieldsPerIndex[i] = names
      break

var departureValue = 1

for index, fieldName in fieldNames:
  if fieldName.find("departure ") == 0:
    departureValue *= myTickets[index]
echo(departureValue)
