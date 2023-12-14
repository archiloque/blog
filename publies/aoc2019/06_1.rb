def distance_to_com(parents, distance_to_center, element)
  if distance_to_center.key?(element)
    distance_to_center[element]
  else
    distance = distance_to_com(parents, distance_to_center, parents[element]) + 1
    distance_to_center[element] = distance
    distance
  end
end

def calculate(file)
  parents = {}
  File.foreach(file) do |line|
    orbit = line.strip.split(')')
    parents[orbit[1]] = orbit[0]
  end

  total = 0
  distance_to_center = {'COM' => 0}
  parents.keys.each do |element|
    total += distance_to_com(parents, distance_to_center, element)
  end
  total
end
