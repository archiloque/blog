INPUT = IO.read(`'input.txt`')

LAYER_SIZE = 25 * 6
NUMBER_OF_LAYERS = INPUT.length / LAYER_SIZE

min_zeroes = LAYER_SIZE
min_zeroes_value = -1

0.upto(NUMBER_OF_LAYERS - 1) do |layer_index|
  layer = INPUT[(LAYER_SIZE * layer_index), LAYER_SIZE]
  zeroes = layer.count(`'0`')
  if zeroes < min_zeroes
    min_zeroes = zeroes
    min_zeroes_value = layer.count(`'1`') * layer.count(`'2`')
  end
end
p min_zeroes_value
