import strutils
import sequtils
import os
import re

const allowedPassportFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"]
const requiredPassportFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

let yearRegex = re(r"^(\d{4})$")
let sizeRegex = re(r"^(\d{2,3})(cm|in)$")
let hairColorRegex = re(r"^#([\da-f]{6})$")
const hairColors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
let passportIdRegex = re(r"^(\d{9})$")

proc validValue(fieldName: string, fieldValue: string): bool =
  case fieldName:
    of "byr":
      if fieldValue.match(yearRegex):
        let yearValue = fieldValue.parseInt()
        if (yearValue >= 1920) and (yearValue <= 2002):
          return true
    of "iyr":
      if fieldValue.match(yearRegex):
        let yearValue = fieldValue.parseInt()
        if (yearValue >= 2010) and (yearValue <= 2020):
          return true
    of "eyr":
      if fieldValue.match(yearRegex):
        let yearValue = fieldValue.parseInt()
        if (yearValue >= 2020) and (yearValue <= 2030):
          return true
    of "hgt":
      var matches: array[2, string]
      if fieldValue.match(sizeRegex, matches):
        let heightValue = matches[0].parseInt()
        case matches[1]:
          of "cm":
            if (heightValue >= 150) and (heightValue <= 193):
              return true
          of "in":
            if (heightValue >= 59) and (heightValue <= 76):
              return true
    of "hcl":
      if fieldValue.match(hairColorRegex):
        return true
    of "ecl":
      if hairColors.contains(fieldValue):
        return true
    of "pid":
      if fieldValue.match(passportIdRegex):
        return true
    of "cid":
      return true
  return false

let input: seq[string] = readFile(paramStr(1)).splitLines()
var validPassportNumber = 0
var currentPassportFields = newSeq[string]()
for passportLine in input:
  echo("[", passportLine, "]")
  if passportLine == "":
    if requiredPassportFields.allIt(it in currentPassportFields):
      echo("Valid")
      validPassportNumber += 1
    else:
      echo("Invalid")
    currentPassportFields = newSeq[string]()
  else:
    for field in passportLine.split(" "):
      let splittedField = field.split(":")
      let fieldName = splittedField[0]

      if not allowedPassportFields.contains(fieldName):
        raise newException(ValueError, "Unknown field [" & fieldName & "]")
      elif currentPassportFields.contains(fieldName):
        raise newException(ValueError, "Duplicated field [" & fieldName & "]")
      let fieldValue = splittedField[1]
      echo("[", fieldName, "] [", fieldValue, "]")
      if validValue(fieldName, fieldValue):
        echo(true)
        currentPassportFields.add(fieldName)
      else:
        echo(false)

if requiredPassportFields.allIt(it in currentPassportFields):
  validPassportNumber += 1

echo(validPassportNumber)
