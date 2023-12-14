def path_to_com(parents, element)
  result = []
  current_element = parents[element]
  until current_element == 'COM'
    result << current_element
    current_element = parents[current_element]
  end
  result
end

def calculate(file)
  parents = {}
  File.foreach(file) do |line|
    orbit = line.strip.split(')')
    parents[orbit[1]] = orbit[0]
  end

  you_path = path_to_com(parents, 'YOU')
  san_path = path_to_com(parents, 'SAN')
  (you_path - san_path).length + (san_path - you_path).length
end
