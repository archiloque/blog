# @param [Integer] mass
def fuel(mass)
  (mass.to_f / 3.0).floor - 2
end

assert_equal(2, fuel(12))
assert_equal(2, fuel(14))
assert_equal(654, fuel(1969))
assert_equal(33583, fuel(100756))

result = 0
File.foreach('input.txt') do |line|
  result += fuel(line.strip.to_i)
end
p result
