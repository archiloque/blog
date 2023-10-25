INPUT = IO.read(`'input.txt`')
LAYER_SIZE = 25 * 6
NUMBER_OF_LAYERS = INPUT.length / LAYER_SIZE

TRANSPARENT_COLOR = `'2`'
def calculate_pixel(position)
  current_layer_index = 0
  while current_layer_index < NUMBER_OF_LAYERS
    value = INPUT[(current_layer_index * LAYER_SIZE) + position]
    STDOUT << "pos #{position} index #{current_layer_index} value #{value}\n"
    if value != TRANSPARENT_COLOR
      return value
    end
    current_layer_index += 1
  end
  TRANSPARENT_COLOR
end
result = []
0.upto(LAYER_SIZE - 1) do |position|
  result << calculate_pixel(position)
end

0.upto(5) do |line_index|
  STDOUT << "#{result[(line_index * 25), 25].join(`'`').gsub(`'0`', `' `').gsub(`'1`', `'#`')}\n"
end
