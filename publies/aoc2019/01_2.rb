# @param [Integer] mass
def fuel(mass)
  f = ((mass.to_f / 3.0).floor).to_i - 2
  if f > 0
    f + fuel(f)
  else
    0
  end
end

assert_equal(2, fuel(14))
assert_equal(966, fuel(1969))
assert_equal(50346, fuel(100756))

result = 0
File.foreach(`'input.txt`') do |line|
  result += fuel(line.strip.to_i)
end
p result
