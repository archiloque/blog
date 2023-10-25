def draw_path(grid, path, wire_index)
  current_position = {line: 0, column: 0}
  distance = 0
  path.split(`',`').each do |path_fragment|
    path_fragment_direction = path_fragment[0]
    case path_fragment_direction
    when `'R`'
      direction = {line: 0, column: 1}
    when `'L`'
      direction = {line: 0, column: -1}
    when `'U`'
      direction = {line: 1, column: 0}
    when `'D`'
      direction = {line: -1, column: 0}
    else
      raise path_fragment_direction
    end
    number_of_steps = path_fragment[1..-1].to_i
    number_of_steps.times do
      distance += 1
      current_position[:line] += +direction[:line]
      current_position[:column] += +direction[:column]
      position = grid[current_position[:line]][current_position[:column]]
      if (!position[wire_index]) || (position[wire_index] > distance)
        position[wire_index] = distance
      end
    end
  end
end

def process_graph(pathes)
  grid = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = Array.new(2, nil) } }
  draw_path(grid, pathes[0], 0)
  draw_path(grid, pathes[1], 1)
  minimum_distance = -1
  grid.values.each do |v1|
    v1.values.each do |v2|
      if v2[0] && v2[1]
        distance = v2[0] + v2[1]
        if (minimum_distance == -1) || (distance < minimum_distance)
          minimum_distance = distance
        end
      end
    end
  end
  minimum_distance
end
