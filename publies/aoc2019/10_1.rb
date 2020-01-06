require 'set'

ASTEROID_CHAR = '#'
# @param [String] field
# @return [Hash]
def process(field)
  splitted_field = field.split("\n")
  lines_nb = splitted_field.length
  columns_nb = splitted_field[0].length
  asteroids = []
  0.upto(lines_nb - 1) do |line|
    0.upto(columns_nb - 1) do |column|
      if splitted_field[line][column] == ASTEROID_CHAR
        asteroids << {column: column, line: line}
      end
    end
  end
  p asteroids
  max_asteroid_position = nil
  max_asteroid_number = 0
  asteroids.each_with_index do |from_asteroid, from_index|
    STDOUT << "from #{from_asteroid}\n"
    asteroids_with_delta_positive = Set.new
    asteroids_with_delta_negative = Set.new
    above = false
    under = false
    asteroids.each_with_index do |to_asteroid, to_index|
      if from_index != to_index
        STDOUT << "  to #{to_asteroid} "
        delta_column = from_asteroid[:column] - to_asteroid[:column]
        delta_line = from_asteroid[:line] - to_asteroid[:line]
        if delta_column > 0
          STDOUT << "#{Rational(delta_line, delta_column)}\n"
          asteroids_with_delta_positive << Rational(delta_line, delta_column)
        elsif delta_column < 0
          STDOUT << "#{Rational(delta_line, delta_column)}\n"
          asteroids_with_delta_negative << Rational(delta_line, delta_column)
        elsif delta_line > 0
          STDOUT << "under\n"
          above = true
        else
          STDOUT << "above\n"
          under = true
        end
      end
    end
    visible_number = asteroids_with_delta_positive.length + asteroids_with_delta_negative.length + (above ? 1 : 0) + (under ? 1 : 0)
    STDOUT << "Can see #{visible_number} #{asteroids_with_delta_positive} #{asteroids_with_delta_negative} #{above} #{under}\n\n"
    if visible_number > max_asteroid_number
      max_asteroid_number = visible_number
      max_asteroid_position = from_asteroid
    end
  end
  max_asteroid_position.merge({visible: max_asteroid_number})
end
