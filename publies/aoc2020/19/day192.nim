import strutils
import os
import re
import tables
import sequtils

var input: seq[string] = readFile(paramStr(1)).splitLines()

let ruleSingleLetterRegex = re("""^(\d+): "([a-z])"$""")
let ruleCompositionRegex = re(r"^(\d+): ([\d |]+)$")

type
  Rule = ref object
    index: int
    content: string
    singleChar: bool

proc calculateSubRule(subRule: string): string =
  "(" & subRule.strip().split(" ").map(proc(
      element: string): string = "(?&rule_" & element & ")").join(
          "") & ")"

proc calculateRule(rule: Rule): string =
  result = "(?<rule_" & $rule.index & ">"
  if rule.singleChar:
    result &= rule.content
  else:
    result &= rule.content.strip().split("|").map(proc(
      subRule: string): string = calculateSubRule(subRule)).join("|")
  result &= ")"

let rulesById = newTable[int, Rule]()

var ruleSingleLetterMatch: array[2, string]
var ruleCompositionMatch: array[2, string]

var inputLineIndex = 0
while input[inputLineIndex] != "":
  let currentLine = input[inputLineIndex]
  if currentLine.match(ruleSingleLetterRegex, ruleCompositionMatch):
    let ruleIndex = ruleCompositionMatch[0].parseInt()
    let letter = ruleCompositionMatch[1]
    let rule = Rule(index: ruleIndex, content: letter,
        singleChar: true)
    rulesById[ruleIndex] = rule
  elif currentLine.match(ruleCompositionRegex, ruleCompositionMatch):
    let ruleIndex = ruleCompositionMatch[0].parseInt()
    let rule = Rule(index: ruleIndex, content: ruleCompositionMatch[1],
        singleChar: false)
    rulesById[ruleIndex] = rule
  else:
    raise newException(ValueError, "Can`'t parse [" & currentLine & "]")
  inputLineIndex += 1

var regex = "(?(DEFINE)"
for ruleIndex, rule in rulesById:
  if ruleIndex != 0:
    regex &= rule.calculateRule()
regex &= ")^" & rulesById[0].calculateRule() & "$"

echo(regex)
# Nim doesn`'t support PCRE Regex so I used perl for the answer :
# perl -ne `'while(/THE_REX/g){print "$&\n";}`' FILE_NAME | wc -l
