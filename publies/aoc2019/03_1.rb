def draw_path(grid, path, wire)
  current_position = {line: 0, column: 0}
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
      current_position[:line] += +direction[:line]
      current_position[:column] += +direction[:column]
      grid[current_position[:line]][current_position[:column]] << wire
    end
  end
end

def process_graph(pathes)
  grid = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = [] } }
  draw_path(grid, pathes[0], `'A`')
  draw_path(grid, pathes[1], `'B`')
  distance = 1
  while true
    distance.downto(0) do |line|
      column = distance - line
      if grid[line][column].uniq.length == 2
        return distance
      end
      if grid[line][-column].uniq.length == 2
        return distance
      end
      if grid[-line][column].uniq.length == 2
        return distance
      end
      if grid[-line][-column].uniq.length == 2
        return distance
      end
    end
    distance += 1
  end
end
