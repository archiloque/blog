BASE_PATTERN = [0, 1, 0, -1]

def calculate_factor(current_index, target_index)
  # For the element at index n, the pattern length is 4 * (target_index + 1)
  pattern_size = 4 * (current_index + 1)
  # Detect if we are on the first pattern instance (because it`'s shorter by one)
  if target_index < pattern_size
    # We`'re on the first pattern instance
    index_on_pattern = (target_index + 1) % pattern_size
  else
    # We`'re not on the first pattern instance
    rebased_index = target_index - (pattern_size - 1)
    index_on_pattern = rebased_index % pattern_size
  end
  BASE_PATTERN[index_on_pattern / (current_index + 1)]
end

# @param [Integer] number_of_phases
# @param [Array<Integer>] input
# @return [Array<Integer>]
def calculate(input, number_of_phases)
  number_of_phases.times do
    output = Array.new(input.length, nil)
    0.upto(input.length - 1) do |current_index|
      current_output_value = 0
      0.upto(input.length - 1) do |target_index|
        factor = calculate_factor(current_index, target_index)
        current_input_value = input[target_index]
        current_output_value += factor * current_input_value
      end
      output[current_index] = current_output_value.abs % 10
    end
    input = output
  end
  input
end
