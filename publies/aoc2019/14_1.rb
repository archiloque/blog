ELEMENT_REGEX = /\A\s*(?<quantity>\d+) (?<element>[A-Z]+)\s*\z/

def parse_element(s)
  m = ELEMENT_REGEX.match(s)
  {
      element: m[`'element`'],
      quantity: m[`'quantity`'].to_i
  }
end

FUEL = `'FUEL`'
ORE = `'ORE`'

def find_rank(element, recipes)
  recipe = recipes[element]
  recipe[:rank] = (recipe[:requirements].keys.collect do |required_element|
    if required_element == ORE
      0
    else
      find_rank(required_element, recipes)
    end
  end.max + 1)
end

# @param [String] input_recipes
# @return [Integer]
def process(input_recipes)
  p `'`'
  recipes = {}
  input_recipes.split("\n").each do |input_recipe|
    parts = input_recipe.split(`'=>`')
    result = parse_element(parts[1])
    requirements_array = parts[0].split(`',`').collect { |e| parse_element(e) }
    requirements_hash = {}
    requirements_array.each do |r|
      requirements_hash[r[:element]] = r[:quantity]
    end

    recipes[result[:element]] = {
        quantity: result[:quantity],
        requirements: requirements_hash
    }
  end

  recipes.keys.each do |element|
    find_rank(element, recipes)
  end
  p recipes

  elements_requirements = recipes.delete(FUEL)[:requirements]
  ore_requirements = 0
  until elements_requirements.empty?
    p "Currently #{elements_requirements.length} requirements #{elements_requirements}"

    required_element = elements_requirements.keys.sort_by { |element| recipes[element][:rank] }.last
    required_quantity = elements_requirements.delete(required_element)

    p "Need #{required_quantity} of #{required_element}"
    recipe = recipes.delete(required_element)
    p "Recipe #{recipe}"
    recipe_quantity = (required_quantity.to_f / recipe[:quantity].to_f).ceil
    p "Recipes will be run #{recipe_quantity} times"

    recipe[:requirements].each_pair do |el, quant|
      required_quant = recipe_quantity * quant
      p "Require #{required_quant} of #{el}"
      if el == ORE
        ore_requirements += required_quant
      else
        elements_requirements[el] = (elements_requirements[el] || 0) + required_quant
      end
    end
  end
  ore_requirements
end
