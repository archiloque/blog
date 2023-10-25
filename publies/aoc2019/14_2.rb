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
def prepare_recipes(input_recipes)
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
  recipes
end

# @return [Integer]
def process(recipes, number_of_fuel)
  elements_requirements = {}
  recipes[FUEL][:requirements].each_pair do |k, v|
    elements_requirements[k] = v * number_of_fuel
  end
  ore_requirements = 0
  until elements_requirements.empty?
    required_element = elements_requirements.keys.sort_by { |element| recipes[element][:rank] }.last
    required_quantity = elements_requirements.delete(required_element)

    recipe = recipes[required_element]
    recipe_quantity = (required_quantity.to_f / recipe[:quantity].to_f).ceil

    recipe[:requirements].each_pair do |el, quant|
      required_quant = recipe_quantity * quant
      if el == ORE
        ore_requirements += required_quant
      else
        elements_requirements[el] = (elements_requirements[el] || 0) + required_quant
      end
    end
  end
  ore_requirements
end

TOTAL_ORE = 1000000000000

def process2(input_recipes)
  recipes = prepare_recipes(input_recipes)
  current_max = 1
  current_min = current_max
  while process(recipes, current_max) <= TOTAL_ORE
    current_min = current_max
    current_max = current_max * 2
  end

  p `'!`'
  p current_max

  while current_max != (current_min + 1)
    new_value = (current_min + current_max) / 2
    p new_value
    ore = process(recipes, new_value)
    if ore < TOTAL_ORE
      current_min = new_value
      p "Under"
    else
      current_max = new_value
      p "Above"
    end
  end
  current_min
end
