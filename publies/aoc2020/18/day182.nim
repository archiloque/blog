import strutils
import os
import re

var formulas: seq[string] = readFile(paramStr(1)).splitLines()

let additionRegex = re(r"^(.*?)(\d+) \+ (\d+)(.*?)$")
let multiplicationRegex = re(r"^(.*?)(\d+) \* (\d+)(.*?)$")
let parenthesisRegex = re(r"^(.*)\(([^\(\)]+)\)(.*)$")

proc calculateFormulaWithoutParenthesis(formula: string): string =
  var calculationMatch: array[4, string]
  var innerFormula = formula
  var lastPassDidSomething = true
  while lastPassDidSomething:
    lastPassDidSomething = false
    if innerFormula.match(additionRegex, calculationMatch):
      lastPassDidSomething = true
      let first = calculationMatch[1].parseInt
      let second = calculationMatch[2].parseInt
      var calculationResult = first + second
      innerFormula = calculationMatch[0] & $calculationResult &
          calculationMatch[3]
    elif innerFormula.match(multiplicationRegex, calculationMatch):
      lastPassDidSomething = true
      let first = calculationMatch[1].parseInt
      let second = calculationMatch[2].parseInt
      var calculationResult = first * second
      innerFormula = calculationMatch[0] & $calculationResult &
          calculationMatch[3]
  innerFormula

proc simplifyParenthesis(formula: string): string =
  var parenthesisMatch: array[3, string]
  if formula.match(parenthesisRegex, parenthesisMatch):
    return parenthesisMatch[0] & calculateFormulaWithoutParenthesis(
        parenthesisMatch[1]) & parenthesisMatch[2]
  else:
    raise newException(ValueError, "Can't parse [" & formula & "]")

var total = 0
for formula in formulas:
  var currentFormula = formula
  while currentFormula.find('(') != -1:
    currentFormula = simplifyParenthesis(currentFormula)
  var formulaResult = calculateFormulaWithoutParenthesis(
      currentFormula).parseInt
  total += formulaResult
echo(total)
