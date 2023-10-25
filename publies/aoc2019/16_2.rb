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

# @param [String] s_input
# @return [String]
def calculate(s_input)
  delta = s_input[0, 7].to_i
  input = (s_input.split(`'`').map(&:to_i) * 10000)[delta..-1]
  100.times do
    value = 0
    (input.length - 1).downto(0) do |index|
      value += input[index]
      value = value.abs % 10
      input[index] = value
    end
  end
  input[0, 8].join(`'`')
end
