require 'set'

ASTEROID_CHAR = '#'
# @param [String] field
# @return [Array]
def process(field, station_column, station_line)
  splitted_field = field.split("\n")
  lines_nb = splitted_field.length
  columns_nb = splitted_field[0].length
  number_of_asteroids = 0
  left_quadrant = Hash.new { |hash, key| hash[key] = [] }
  right_quadrant = Hash.new { |hash, key| hash[key] = [] }
  above = []
  under = []

  0.upto(lines_nb - 1) do |line|
    0.upto(columns_nb - 1) do |column|
      if splitted_field[line][column] == ASTEROID_CHAR
        if (line != station_line) || (column != station_column)
          number_of_asteroids += 1
          asteroid = {
              column: column,
              line: line,
              distance: ((line - station_line) ** 2) + ((column - station_column) ** 2)
          }

          delta_column = station_column - column
          delta_line = station_line - line
          if delta_column > 0
            #STDOUT << "#{Rational(delta_line, delta_column)}\n"
            left_quadrant[Rational(delta_line, delta_column)] << asteroid
          elsif delta_column < 0
            #STDOUT << "#{Rational(delta_line, delta_column)}\n"
            right_quadrant[Rational(delta_line, delta_column)] << asteroid
          elsif delta_line > 0
            #STDOUT << "under\n"
            above << asteroid
          else
            #STDOUT << "above\n"
            under << asteroid
          end
        end
      end
    end
  end
  (right_quadrant.values + left_quadrant.values + [above, under]).each do |asteriods|
    asteriods.sort_by!{|a| a[:distance]}
  end
  result = []
  quadrants = [
      {0 => above},
      right_quadrant,
      {0 => under},
      left_quadrant
  ]

  p above
  p right_quadrant
  p under
  p left_quadrant


  while result.length < number_of_asteroids
    quadrants.each do |quadrant|
      quadrant.keys.sort.each do |angle|
        asteroids = quadrant[angle]
        result << asteroids.shift
        if asteroids.empty?
          quadrant.delete(angle)
        end
      end
    end
  end
  result
end
