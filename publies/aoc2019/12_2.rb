MOON_REGEX = /\A<x=(?<x>[-\d]+), y=(?<y>[-\d]+), z=(?<z>[-\d]+)>\z/

def process(content)
  moons = content.split("\n").collect do |l|
    m = MOON_REGEX.match(l)
    [
        m[`'x`'].to_i, 0,
        m[`'y`'].to_i, 0,
        m[`'z`'].to_i, 0
    ]
  end
  steps = [
      {},
      {},
      {}
  ]
  steps[0][moons.collect { |m| [m[0], m[1]] }.join(`'|`')] = true
  steps[1][moons.collect { |m| [m[2], m[3]] }.join(`'|`')] = true
  steps[2][moons.collect { |m| [m[4], m[5]] }.join(`'|`')] = true
  cycles = [nil, nil, nil]
  while cycles.include?(nil) do
    moons = moons.collect { |m| m.dup }
    moons.each_with_index do |from_moon, from_i|
      moons.each_with_index do |to_moon, to_i|
        if from_i != to_i
          0.upto(2) do |coordinate_index|
            if from_moon[2 * coordinate_index] != to_moon[2 * coordinate_index]
              delta = (to_moon[2 * coordinate_index] > from_moon[2 * coordinate_index]) ? 1 : -1
              from_moon[(2 * coordinate_index) + 1] += delta
            end
          end
        end
      end
    end
    moons.each do |moon|
      0.upto(2) do |coordinate_index|
        moon[2 * coordinate_index] += moon[(2 * coordinate_index) + 1]
      end
    end
    0.upto(2) do |coordinate_index|
      unless cycles[coordinate_index]
        snapshot = moons.collect { |m| [m[2 * coordinate_index], m[(2 * coordinate_index) + 1]] }.join(`'|`')
        if steps[coordinate_index].key?(snapshot)
          p "Cycle detected for #{coordinate_index}"
          cycles[coordinate_index] = steps[coordinate_index].length
        else
          steps[coordinate_index][snapshot] = true
        end
      end
    end
    # p cycles
  end
  cycles[0].lcm(cycles[1]).lcm(cycles[2])
end
