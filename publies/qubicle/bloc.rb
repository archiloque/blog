# Represents a block
class Bloc

  # @return [Integer]
  attr_reader :r
  
  # @return [Integer]
  attr_reader :g
  
  # @return [Integer]
  attr_reader :b
  
  # @return [Integer]
  attr_reader :x
  
  # @return [Integer]
  attr_reader :y
  
  # @return [Integer]
  attr_reader :z
  
  # @param [Integer] r_value
  # @param [Integer] g_value
  # @param [Integer] b_value
  # @param [Integer] x_value
  # @param [Integer] y_value
  # @param [Integer] z_value
  # @raise [RuntimeError]  if a value is bad
  def initialize(r_value, g_value, b_value, x_value, y_value, z_value)
    check_color(r_value)
    @r = r_value
    check_color(g_value)
    @g = g_value
    check_color(b_value)
    @b = b_value
  
    check_position(x_value)
    @x = x_value
  
    check_position(y_value)
    @y = y_value
  
    check_position(z_value)
    @z = z_value
  end
  
  def r=(r_value)
    check_color(r_value)
    @r = r_value
  end
  
  def g=(g_value)
    check_color(g_value)
    @g = g_value
  end
  
  def b=(b_value)
    check_color(b_value)
    @b = b_value
  end
  
  def x=(x_value)
    check_position(x_value)
    @x = x_value
  end
  
  def y=(y_value)
    check_position(y_value)
    @y = y_value
  end
  
  def z=(z_value)
    check_position(z_value)
    @z = z_value
  end
  
  private
  
  # @param [Integer] value
  # @return [void]
  # @raise [RuntimeError]  if a value is bad
  def check_color(value)
    raise "Value #{value} should be an integer" unless value.is_a? Integer
    if value < 0
      raise "Value #{value} should be >= 0"
    elsif value > 254
      raise "Value #{value} should be <= 254"
    end
  end
  
  # @param [Integer] value
  # @return [void]
  # @raise [RuntimeError]  if a value is bad
  def check_position(value)
    raise "Value #{value} should be an integer" unless value.is_a? Integer
    if value < 0
      raise "Value #{value} should be >= 0"
    end
  end
  
end
  