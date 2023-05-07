INGREDIENTS_REGEX = /\A(.+) x(\d+)\z/

sources = IO.read('sources.txt').split("\n").map{|i| i.strip}
recipes = IO.read('recipes-2.txt').split("\n").map{|i| i.split(',').map{|e| e.strip } << 1}

File.foreach('recipes-1.txt') do |line|
    line = line.strip().split("\t")
    sources = line[1].split(',').map{|e| e.strip}
    sources.each do |source|
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
main_coponents = []

in_block do
    STDOUT << "#{recipe_to_find} = "
    recipes.each do |recipe|
        if recipe[1] == recipe_to_find
            main_coponents << recipe[0]
        end
    end
    main_coponents.sort!
    components_formatted = main_coponents.map do |component|
        "1 * #{component}"
    end
    STDOUT << "#{components_formatted.join(' + ')}\n"
end

main_coponents.each do |main_coponent|
    in_block do
    end
end