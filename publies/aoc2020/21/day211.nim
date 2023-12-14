import strutils
import os
import re
import tables
import sets
import math
import algorithm
import sequtils

type
  Recipe = ref object
    ingredients: HashSet[string]
    allergens: HashSet[string]

var recipes: seq[Recipe] = @[]

let recipeRegex = re(r"^(.+) \(contains (.+)\)$")

var allAllergens = initHashSet[string]()
var allIngredients = initHashSet[string]()

var recipeMatch: array[2, string]
for currentLine in readFile(paramStr(1)).splitLines():
  if currentLine.match(recipeRegex, recipeMatch):
    let allergens = recipeMatch[1].split(", ")
    for allergen in allergens:
      allAllergens.incl(allergen)
    let ingredients = recipeMatch[0].split(" ")
    for ingredient in ingredients:
      allIngredients.incl(ingredient)
    recipes.add(Recipe(ingredients: ingredients.toHashSet(),
        allergens: allergens.toHashSet()))
  else:
    raise newException(ValueError, "Can't parse [" & currentLine & "]")

var possibleIngredientsForAllergens = initTable[string, HashSet[string]]()

for allergen in allAllergens:
  var possibleIngredientsForAllergen = allIngredients
  for recipe in recipes:
    if recipe.allergens.contains(allergen):
      possibleIngredientsForAllergen = possibleIngredientsForAllergen.intersection(
          recipe.ingredients)
  possibleIngredientsForAllergens[allergen] = possibleIngredientsForAllergen

var foundIngredient = true
while foundIngredient:
  foundIngredient = false
  for allergen, possibleIngredients in possibleIngredientsForAllergens:
    if possibleIngredients.len() == 1:
      let ingredient = possibleIngredients.toSeq()[0]
      foundIngredient = true
      allAllergens.excl(allergen)
      allIngredients.excl(ingredient)
      possibleIngredientsForAllergens.del(allergen)
      for recipe in recipes:
        recipe.ingredients.excl(ingredient)
        recipe.allergens.excl(allergen)
      for a, i in possibleIngredientsForAllergens:
        if i.contains(ingredient):
          var iWithoutIngredient = i
          iWithoutIngredient.excl(ingredient)
          possibleIngredientsForAllergens[a] = iWithoutIngredient
      break

var ingredientsCount = 0
for currentLine in readFile(paramStr(1)).splitLines():
  if currentLine.match(recipeRegex, recipeMatch):
    let ingredients = recipeMatch[0].split(" ")
    for ingredient in ingredients:
      if allIngredients.contains(ingredient):
        ingredientsCount += 1
  else:
    raise newException(ValueError, "Can't parse [" & currentLine & "]")
echo(ingredientsCount)
