MOON_REGEX = /\A<x=(?<x>[-\d]+), y=(?<y>[-\d]+), z=(?<z>[-\d]+)>\z/

def process(content, steps)
  moons = content.split("\n").collect do |l|
    m = MOON_REGEX.match(l)
    {
        pos: [m[`'x`'].to_i, m[`'y`'].to_i, m[`'z`'].to_i],
        vel: [0, 0, 0]
    }
  end
  steps.times do
    p moons
    moons.each_with_index do |from_moon, from_i|
      moons.each_with_index do |to_moon, to_i|
        if from_i != to_i
          0.upto(2) do |coordinate_index|
            if from_moon[:pos][coordinate_index] != to_moon[:pos][coordinate_index]
              delta = (to_moon[:pos][coordinate_index] > from_moon[:pos][coordinate_index]) ? 1 : -1
              from_moon[:vel][coordinate_index] += delta
            end
          end
        end
      end
    end
    moons.each do |moon|
      0.upto(2) do |coordinate_index|
        moon[:pos][coordinate_index] += moon[:vel][coordinate_index]
      end
    end
  end
  p moons
  moons.collect do |moon|
    moon[:pos].collect(&:abs).sum * moon[:vel].collect(&:abs).sum
  end.sum
end
