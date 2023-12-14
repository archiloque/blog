NUMBER_OF_DIGITS = 6

# @param [Integer] current_number
# @param [Integer] digit_index
# @param [Integer] last_number
def next_digit(current_number, digit_index, last_number, &block)
  last_number.upto(9) do |digit|
    n = current_number + (digit * (10 ** (5 - digit_index)))
    if digit_index == (NUMBER_OF_DIGITS - 1)
      yield(n)
    else
      next_digit(n, digit_index + 1, digit, &block)
    end
  end
end

result = 0

next_digit(0, 0, 0) do |candidate|
  if(candidate >= 246515) && (candidate <= 739105) && (candidate.to_s.split(//).uniq.count < NUMBER_OF_DIGITS)
    p candidate
    result += 1
  end
end
p ''
p result