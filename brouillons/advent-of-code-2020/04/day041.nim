import strutils
import sequtils
import os

const allowedPassportFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"]
const requiredPassportFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

let input: seq[string] = readFile(paramStr(1)).splitLines()
var validPassportNumber = 0
var currentPassportFields = newSeq[string]()
for passportLine in input:
  echo("[", passportLine, "]")
  if passportLine == "":
    if requiredPassportFields.allIt(it in currentPassportFields):
      validPassportNumber += 1
    currentPassportFields = newSeq[string]()
  else:
    for field in passportLine.split(" "):
      let fieldName = field.split(":")[0]
      if not allowedPassportFields.contains(fieldName):
        raise newException(ValueError, "Unknown field [" & fieldName & "]")
      elif currentPassportFields.contains(fieldName):
        raise newException(ValueError, "Duplicated field [" & fieldName & "]")
      currentPassportFields.add(fieldName)

if requiredPassportFields.allIt(it in currentPassportFields):
  validPassportNumber += 1

echo(validPassportNumber)
