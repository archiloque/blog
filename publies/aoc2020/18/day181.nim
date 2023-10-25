import strutils
import os
import re

var formulas: seq[string] = readFile(paramStr(1)).splitLines()

let calculationRegex = re(r"^(\d+) ([\+\*]) (\d+)(.*)$")
let parenthesisRegex = re(r"^(.*)\(([^\(\)]+)\)(.*)$")

proc calculateFormulaWithoutParenthesis(formula: string): string =
  var calculationMatch: array[4, string]
  var innerFormula = formula
  while innerFormula.match(calculationRegex, calculationMatch):
    let first = calculationMatch[0].parseInt
    let second = calculationMatch[2].parseInt
    var calculationResult: int
    case calculationMatch[1]:
      of "*":
        calculationResult = first * second
      of "+":
        calculationResult = first + second
      else:
        raise newException(ValueError, "Unknown operation [" & calculationMatch[
            1] & "]")
    innerFormula = $calculationResult & calculationMatch[3]
  innerFormula

proc simplifyParenthesis(formula: string): string =
  var parenthesisMatch: array[3, string]
  if formula.match(parenthesisRegex, parenthesisMatch):
    return parenthesisMatch[0] & calculateFormulaWithoutParenthesis(
        parenthesisMatch[1]) & parenthesisMatch[2]
  else:
    raise newException(ValueError, "Can`'t parse [" & formula & "]")

var total = 0
for formula in formulas:
  var currentFormula = formula
  while currentFormula.find(`'(`') != -1:
    currentFormula = simplifyParenthesis(currentFormula)
  var formulaResult = calculateFormulaWithoutParenthesis(
      currentFormula).parseInt
  total += formulaResult
echo(total)
