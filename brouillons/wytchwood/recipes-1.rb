require 'set'

def f(text)
    text.split(" ").join('\n')
end

INGREDIENTS_REGEX = /\A(.+) x(\d+)\z/

sources = IO.read('sources.txt').split("\n").map{|i| i.strip}

recipes = IO.read('recipes-2.txt').split("\n").map{|i| i.split(',')}

recipes.each do |recipe|
    recipe << false
end

File.foreach('recipes-1.txt') do |line|
    line = line.strip().split("\t")
    sources = line[1].split(',').map{|e| e.strip}
    sources.each do |source|
        splitted_source = INGREDIENTS_REGEX.match(source)
        from = splitted_source[1]
        to = line[0]
        recipes << [from, to, false]
    end
end

STDOUT << "digraph \"recipes\" {\n"
#STDOUT << "\trankdir=\"LR\"\n"
STDOUT << "\tranksep=1.5\n"
sources.each do |source|
    STDOUT << "\tnode [shape=box] \"#{f(source)}\";\n"
end
STDOUT << "\tnode [shape=ellipse];\n"

ingredients_to_find = [
    "Key to my Heart", 
    "Porcine Effigy", 
    "Magi-Sharp XL", 
    "Silver Bullet", 
    "Feline Curio",
]

found_new = true
while found_new
    found_new = false
    recipes.each do |recipe|
        if ingredients_to_find.include?(recipe[1])
            recipe[2] = true
            unless ingredients_to_find.include?(recipe[0])
                ingredients_to_find << recipe[0]
                found_new = true
            end
        end
    end
end

recipes.each do |recipe|
    STDOUT << "\t\"#{f(recipe[0])}\" -> \"#{f(recipe[1])}\" [weight=#{recipe[2] ? 5 : 1},weight=#{recipe[2] ? 5 : 15}]\n"
end

STDOUT << "}\n"
