INGREDIENTS_REGEX = /\A(.+) x(\d+)\z/

sources = IO.read('sources.txt').split("\n").map{|i| i.strip}
recipes = IO.read('recipes-2.txt').split("\n").map{|i| i.split(',').map{|e| e.strip } << 1}

File.foreach('recipes-1.txt') do |line|
    line = line.strip().split("\t")
    splitted_line = line[1].split(',').map{|e| e.strip}
    splitted_line.each do |source|
        splitted_source = INGREDIENTS_REGEX.match(source)
        from = splitted_source[1]
        to = line[0]
        recipes << [from, to, splitted_source[2].to_i]
    end
end

def in_block()
    STDOUT << "[source]\n"
    STDOUT << "----\n"
    yield
    STDOUT << "----\n\n"
end    

recipe_to_find = "Key to my Heart"
main_components = []

in_block do
    STDOUT << "#{recipe_to_find} = "
    recipes.each do |recipe|
        if recipe[1] == recipe_to_find
            main_components << recipe[0]
        end
    end
    main_components.sort!
    components_formatted = main_components.map do |component|
        "1 × #{component}"
    end
    STDOUT << "#{components_formatted.join(' + ')}\n"
end

def find_recipes(recipes, component)
    recipes.select do |recipe|
        recipe[1] == component
    end
end

main_components.each do |main_component|
    in_block do
        current_components = [main_component]
        while !current_components.empty?
            component = current_components.shift
            unless sources.include?(component)
                component_recipes = find_recipes(recipes, component)
                component_recipes.sort_by!{|recipe| recipe[0]}
                STDOUT << "#{component} = #{component_recipes.map{|recipe| "#{recipe[2]} × #{recipe[0]}" }.join(' + ')}\n"
                component_recipes.reverse.each do |recipe|
                    current_components.unshift(recipe[0])
                end
            end
        end
    end
end

def components_to_s(components)
    components.keys.sort.map{|component| "#{components[component]} × #{component.gsub(" ", " ")}" }.join(' + ')
end

in_block do
    STDOUT << "#{recipe_to_find}\n"
    current_recipe = {}
    main_components.each do |component|
        current_recipe[component] = 1
    end
    STDOUT << "= #{components_to_s(current_recipe)}\n"
    has_changed = true
    while has_changed
        has_changed = false
        new_recipe = Hash.new { |hash, key| hash[key] = 0 }
        current_recipe.each_pair do |component, number|
            if sources.include?(component)
                new_recipe[component] += number
            else
                component_recipes = find_recipes(recipes, component)
                component_recipes.each do |recipe|
                    new_recipe[recipe[0]] += recipe[2] * number
                end
                has_changed = true
            end
        end
        if has_changed
            STDOUT << "= #{components_to_s(new_recipe)}\n"
            current_recipe = new_recipe
        end
    end
end