require `'logger`'

require_relative `'bloc`'

class Qubicle

  MATRIX_NAME = `'all blocks`'

  LOGGER = Logger.new(STDOUT)

  # @param [Array<Bloc>] blocs
  # @param [IO] io
  # @return [void]
  def write(blocs, io)
    LOGGER << "Will write #{blocs.length} blocks\n"

    if blocs.empty?
      raise `'Blocks list should not be empty`'
    end
    
    add_header(io)

    # Add blocks
    first_bloc = blocs.first
    
    min_x = first_bloc.x
    max_x = first_bloc.x
    min_y = first_bloc.y
    max_y = first_bloc.y
    min_z = first_bloc.z
    max_z = first_bloc.z
    
    # Find boundaries
    blocs.each do |bloc|
      x = bloc.x
      if x > max_x
        max_x = x
      end
      if x < min_x
        min_x = x
      end

      y = bloc.y
      if y > max_y
        max_y = y
      end
      if y < min_y
        min_y = y
      end

      z = bloc.z
      if z > max_z
        max_z = z
      end
      if z < min_z
        min_z = z
      end
    end

    x_size = 1 + max_x - min_x
    y_size = 1 + max_y - min_y
    z_size = 1 + max_z - min_z

    LOGGER << "Matrix start at (#{min_x}, #{min_y}, #{min_z})\n"
    LOGGER << "Matrix dimension are (#{x_size}, #{y_size}, #{z_size})\n"

    # Matrix name
    add_1_byte_int(MATRIX_NAME.length, io)
    add_string(MATRIX_NAME, io)

    # Matrix size
    add_4_byte_int(x_size, io)
    add_4_byte_int(y_size, io)
    add_4_byte_int(z_size, io)

    # Matrix position
    add_4_byte_int(min_x, io)
    add_4_byte_int(min_y, io)
    add_4_byte_int(min_z, io)

    matrix_init_position = io.pos

    # Write empty matrix
    (x_size * y_size * z_size).times do
      io << [0, 0, 0, 0].pack(`'C*`')
    end

    blocs.each do |bloc|
      # Calculate where thr bloc is in the matrix
      bloc_x = bloc.x - min_x
      bloc_y = bloc.y - min_y
      bloc_z = bloc.z - min_z

      bloc_position_in_matrix = 4 * (bloc_x  + (bloc_y * x_size) + (bloc_z * y_size * x_size))

      # Go to the position
      io.pos = matrix_init_position + bloc_position_in_matrix

      # Color
      add_1_byte_int(bloc.r, io)
      add_1_byte_int(bloc.g, io)
      add_1_byte_int(bloc.b, io)

      # Set visible
      add_1_byte_int(1, io)
    end
  end

  private

  # @param [IO] io
  # @return [void]
  def add_header(io)
    # Version
    add_1_byte_int(1, io)
    add_1_byte_int(1, io)
    add_1_byte_int(0, io)
    add_1_byte_int(0, io)

    # Color Format
    add_4_byte_int(0, io)

    # Z-Axis Orientation
    add_4_byte_int(1, io)

    # Compression
    add_4_byte_int(0, io)

    # Visibility-Mask encoded
    add_4_byte_int(0, io)

    # Matrix count
    add_4_byte_int(1, io)
  end

  # @param [Integer] content
  # @param [String] io
  # @return [void]
  def add_4_byte_int(content, io)
    io << [content].pack(`'L*`')
  end

  # @param [Integer] content
  # @param [String] io
  # @return [void]
  def add_1_byte_int(content, io)
    io << [content].pack(`'C*`')
  end


  # @param [String] content
  # @param [String] io
  # @return [void]
  def add_string(content, io)
    io << content
  end

end