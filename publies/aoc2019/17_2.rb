LOG_INFO = false

class Amplifier

  STATUS_EXIT = :exit
  STATUS_NEED_INPUT = :need_input
  STATUS_CAN_CONTINUE = :can_continue

  attr_reader :status

  # @param [Array<Integer>] memory
  # @param [Array<Integer>] io_in
  def initialize(memory, io_in, instruction_pointer = 0, relative_base = 0, status = :can_continue)
    @memory = memory
    @io_in = io_in
    @instruction_pointer = instruction_pointer
    @relative_base = relative_base
    @status = status
  end

  def dup
    Amplifier.new(
        @memory.dup,
        @io_in.dup,
        @instruction_pointer,
        @relative_base,
        @status
    )
  end

  # @param [Array<Integer>] input
  # @return [Array<Integer>|nil]
  def resume(input)
    io_out = []
    @io_in.concat(input)
    if LOG_INFO
      STDOUT << "\nResume amplifier with pointer at #{@instruction_pointer} with input #{@io_in}\n"
    end
    while true
      @status = interpret_instruction(io_out)
      case status
      when STATUS_NEED_INPUT
        if LOG_INFO
          STDOUT << "Input needed, output is #{io_out} and pointer at #{@instruction_pointer}\n"
        end
        return io_out
      when STATUS_EXIT
        if LOG_INFO
          STDOUT << "Amplifier stopped\n"
        end
        return io_out
      when STATUS_CAN_CONTINUE
      else
        raise result
      end
    end
  end

  private

  # @param [Integer] index
  # @return [Integer]
  def memory(index)
    @memory[index] || 0
  end

  # @param [Array<Integer>] io_out
  # @return [Symbol] STATUS_EXIT, STATUS_NEED_INPUT or STATUS_CAN_CONTINUE
  def interpret_instruction(io_out)
    instruction = sprintf("%05d", memory(@instruction_pointer))
    opcode = instruction[-2..-1]
    case opcode
    when '01' # add
      print_instruction(instruction, 'add', 3)
      a = value(instruction, 0)
      b = value(instruction, 1)
      c = s_value(instruction, 2)
      log_instruction("Store (#{a} + #{b}) at #{c}")
      @memory[c] = a + b
      @instruction_pointer += 4
      STATUS_CAN_CONTINUE
    when '02' # multiply
      print_instruction(instruction, 'multiply', 3)
      a = value(instruction, 0)
      b = value(instruction, 1)
      c = s_value(instruction, 2)
      log_instruction("Store (#{a} * #{b}) at #{c}")
      @memory[c] = a * b
      @instruction_pointer += 4
      STATUS_CAN_CONTINUE
    when '03' # input
      print_instruction(instruction, 'input', 1)
      if @io_in.empty?
        return STATUS_NEED_INPUT
      end
      a = s_value(instruction, 0)
      log_instruction("Store input at #{a}")
      @memory[a] = @io_in.shift
      @instruction_pointer += 2
      STATUS_CAN_CONTINUE
    when '04' # output
      print_instruction(instruction, 'output', 1)
      a = value(instruction, 0)
      log_instruction("Output #{a}")
      io_out << a
      @instruction_pointer += 2
      STATUS_CAN_CONTINUE
    when '05' # jump-if-true
      print_instruction(instruction, 'jump-if-true', 2)
      a = value(instruction, 0)
      b = value(instruction, 1)
      if a != 0
        log_instruction("Set instruction pointer to #{b} (#{a} != 0)")
        @instruction_pointer = b
      else
        log_instruction("Do nothing (#{a} == 0)")
        @instruction_pointer += 3
      end
      STATUS_CAN_CONTINUE
    when '06' # jump-if-false
      print_instruction(instruction, 'jump-if-false', 2)
      a = value(instruction, 0)
      b = value(instruction, 1)
      if a == 0
        log_instruction("Set instruction pointer to #{b} (#{a} == 0)")
        @instruction_pointer = b
      else
        log_instruction("Do nothing (#{a} != #{0})")
        @instruction_pointer += 3
      end
      STATUS_CAN_CONTINUE
    when '07' # less-than
      print_instruction(instruction, 'less-than', 3)
      a = value(instruction, 0)
      b = value(instruction, 1)
      c = s_value(instruction, 2)
      value = (a < b) ? 1 : 0
      log_instruction("Set #{value} at #{c} (#{a} < #{b})")
      @memory[c] = value
      @instruction_pointer += 4
      STATUS_CAN_CONTINUE
    when '08' # equals
      print_instruction(instruction, 'equals', 3)
      a = value(instruction, 0)
      b = value(instruction, 1)
      c = s_value(instruction, 2)
      value = (a == b) ? 1 : 0
      log_instruction("Set #{value} at #{c} (#{a} == #{b})")
      @memory[c] = value
      @instruction_pointer += 4
      STATUS_CAN_CONTINUE
    when '09' # adjust-relative-base
      print_instruction(instruction, 'adjust-relative-base', 1)
      a = value(instruction, 0)
      log_instruction("Adjust relative base #{@relative_base} + #{a}")
      @relative_base += a
      @instruction_pointer += 2
      STATUS_CAN_CONTINUE
    when '99'
      print_instruction(instruction, 'exit', 0)
      log_instruction("Exit")
      STATUS_EXIT
    else
      raise opcode
    end
  end

  # @param [String] instruction
  # @param [Integer] parameter_index
  # @return [Integer]
  def s_value(instruction, parameter_index)
    instruction_mode = instruction[-(3 + parameter_index)]
    parameter_value = memory(@instruction_pointer + parameter_index + 1)
    case instruction_mode
    when '0' # position
      parameter_value
    when '1' # position
      parameter_value
    when '2' # relative
      parameter_value + @relative_base
    else
      raise instruction_mode
    end
  end

  # @param [String] instruction
  # @param [Integer] parameter_index
  # @return [Integer]
  def value(instruction, parameter_index)
    instruction_mode = instruction[-(3 + parameter_index)]
    parameter_value = memory(@instruction_pointer + parameter_index + 1)
    case instruction_mode
    when '0' # position
      memory(parameter_value)
    when '1' # immediate
      parameter_value
    when '2' # relative
      memory(parameter_value + @relative_base)
    else
      raise instruction_mode
    end
  end

  def print_instruction(
      instruction,
      opcode,
      number_of_params)
    if LOG_INFO
      STDOUT << "#{opcode} #{instruction} #{@memory[@instruction_pointer + 1, number_of_params].join(', ')}".ljust(40)
    end
  end

  def log_instruction(message)
    if LOG_INFO
      STDOUT << "#{message}\n"
    end
  end
end

amplifier = Amplifier.new(IO.read('input.txt').split(',').map(&:to_i), [])
output = amplifier.resume([])
map = output.map(&:chr).join("").split("\n")
map_width = map.first.length
map_height = map.length

number_of_intersections = 0
1.upto(map_width - 2) do |column|
  1.upto(map_height - 2) do |line|
    if (map[line][column] == '#') &&
        (map[line - 1][column] == '#') &&
        (map[line + 1][column] == '#') &&
        (map[line][column - 1] == '#') &&
        (map[line][column + 1] == '#')
      p "#{line}, #{column} is an intersection"
      # map[line][column] = 'x'
      number_of_intersections += 0
    end
  end
end

robot_line = map.index { |l| l.include?('^') }
robot_column = map[robot_line].index('^')

number_of_standard_scaffolds = map.collect { |l| l.count('#') }.sum - number_of_intersections

DIRECTION_NORTH = 'N'
DIRECTION_SOUTH = 'S'
DIRECTION_EAST = 'E'
DIRECTION_WEST = 'W'

DELTA_LINE = {
    DIRECTION_NORTH => -1,
    DIRECTION_SOUTH => 1,
    DIRECTION_EAST => 0,
    DIRECTION_WEST => 0,
}
DELTA_COLUMN = {
    DIRECTION_NORTH => 0,
    DIRECTION_SOUTH => 0,
    DIRECTION_EAST => 1,
    DIRECTION_WEST => -1,
}

DELTA_LINE_TURNING_RIGHT = {
    DIRECTION_NORTH => 0,
    DIRECTION_SOUTH => 0,
    DIRECTION_EAST => 1,
    DIRECTION_WEST => -1,
}
DELTA_COLUMN_TURNING_RIGHT = {
    DIRECTION_NORTH => 1,
    DIRECTION_SOUTH => -1,
    DIRECTION_EAST => 0,
    DIRECTION_WEST => 0,
}
DELTA_LINE_TURNING_LEFT = {
    DIRECTION_NORTH => 0,
    DIRECTION_SOUTH => 0,
    DIRECTION_EAST => -1,
    DIRECTION_WEST => 1,
}
DELTA_COLUMN_TURNING_LEFT = {
    DIRECTION_NORTH => -1,
    DIRECTION_SOUTH => 1,
    DIRECTION_EAST => 0,
    DIRECTION_WEST => 0,
}

DIRECTION_TURNING_LEFT = {
    DIRECTION_NORTH => DIRECTION_WEST,
    DIRECTION_SOUTH => DIRECTION_EAST,
    DIRECTION_EAST => DIRECTION_NORTH,
    DIRECTION_WEST => DIRECTION_SOUTH,
}
DIRECTION_TURNING_RIGHT = {
    DIRECTION_NORTH => DIRECTION_EAST,
    DIRECTION_SOUTH => DIRECTION_WEST,
    DIRECTION_EAST => DIRECTION_SOUTH,
    DIRECTION_WEST => DIRECTION_NORTH,
}

def can_go_on?(line, column, map_height, map_width, map)
  (line >= 0) && (column >= 0) && (line < map_height) && (column < map_width) && (map[line][column] == '#')
end

def find_path(map, robot_line, robot_column, map_height, map_with)
  current_direction = DIRECTION_NORTH
  current_path = []
  current_line = robot_line
  current_column = robot_column

  while true
    p "(#{current_line}, #{current_column}) going #{current_direction}"
    target_line = current_line + DELTA_LINE[current_direction]
    target_column = current_column + DELTA_COLUMN[current_direction]
    if can_go_on?(target_line, target_column, map_height, map_with, map)
      current_path[-1] += 1
      current_line = target_line
      current_column = target_column
    else
      target_line = current_line + DELTA_LINE_TURNING_LEFT[current_direction]
      target_column = current_column + DELTA_COLUMN_TURNING_LEFT[current_direction]
      if can_go_on?(target_line, target_column, map_height, map_with, map)
        p "Turning left"
        current_path << 'L'
        current_path << 1
        current_line = target_line
        current_column = target_column
        current_direction = DIRECTION_TURNING_LEFT[current_direction]
      else
        target_line = current_line + DELTA_LINE_TURNING_RIGHT[current_direction]
        target_column = current_column + DELTA_COLUMN_TURNING_RIGHT[current_direction]
        if can_go_on?(target_line, target_column, map_height, map_with, map)
          p "Turning right"
          current_path << 'R'
          current_path << 1
          current_line = target_line
          current_column = target_column
          current_direction = DIRECTION_TURNING_RIGHT[current_direction]
        else
          p "Stuck at (#{current_line}, #{current_column}) !"
          return current_path
        end
      end
    end
  end
end

find_path(map, robot_line, robot_column, map_height, map_width)

def format_code(code)
  result = []
  code.each_with_index do |c, index|
    if index != 0
      result << ','.ord
    end
    result.concat(c.to_s.chars.map(&:ord))
  end
  result + [10]
end

# I did the calculation by hand as it's not too difficult
main_routine = format_code(['A', 'B', 'A', 'B', 'C', 'C', 'B', 'A', 'B', 'C'])
function_a = format_code(['L', 12, 'L', 10, 'R', 8, 'L', 12])
function_b = format_code(['R', 8, 'R', 10, 'R', 12])
function_c = format_code(['L', 10, 'R', 12, 'R', 8])

memory = IO.read('input.txt').split(',').map(&:to_i)
memory[0] = 2
program = main_routine + function_a + function_b + function_c + ['n'.ord, 10]
amplifier = Amplifier.new(memory, program)
p amplifier.resume([]).last
