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

MOVEMENT_NORTH = 1
MOVEMENT_SOUTH = 2
MOVEMENT_EAST = 3
MOVEMENT_WEST = 4

RESULT_WALL = 0
RESULT_MOVED = 1
RESULT_FOUND = 2

memory = IO.read('input.txt').split(',').map(&:to_i)
places_to_try = []
map = Hash.new { |hash, key| hash[key] = {} }


initial_amplifier = Amplifier.new(memory.dup, [])
places_to_try << {
    path: [MOVEMENT_NORTH],
    target_line: -1,
    target_column: 0,
    amplifier: initial_amplifier
}
places_to_try << {
    path: [MOVEMENT_SOUTH],
    target_line: 1,
    target_column: 0,
    amplifier: initial_amplifier
}
places_to_try << {
    path: [MOVEMENT_EAST],
    target_line: 0,
    target_column: 1,
    amplifier: initial_amplifier
}
places_to_try << {
    path: [MOVEMENT_WEST],
    target_line: 0,
    target_column: -1,
    amplifier: initial_amplifier
}

def draw_map(map)
  min_line = map.keys.min
  max_line = map.keys.max
  min_column = map.values.collect { |v| v.keys.min }.compact.min
  max_column = map.values.collect { |v| v.keys.max }.compact.max

  min_line.upto(max_line) do |line|
    min_column.upto(max_column) do |column|
      if map[line].key?(column)
        v = map[line][column]
        if v < 0
          STDOUT << 'O'
        else
          STDOUT << ['#', '.', '2'][v]
        end
      else
        STDOUT << '#'
      end
    end
    STDOUT << "\n"
  end
end

max_path = 0

oxygen_system_line = nil
oxygen_system_column = nil

until places_to_try.empty? do
  place_to_try = places_to_try.shift
  unless map[place_to_try[:target_line]].key?(place_to_try[:target_column])
    amplifier = place_to_try[:amplifier].dup
    output = amplifier.resume([place_to_try[:path].last])
    status = output.last
    map[place_to_try[:target_line]][place_to_try[:target_column]] = status
    case status
    when RESULT_WALL
    else
      if (status == RESULT_FOUND)
        oxygen_system_line = place_to_try[:target_line]
        oxygen_system_column = place_to_try[:target_column]
      end
      if place_to_try[:path].length > max_path
        max_path = place_to_try[:path].length
      end
      [
          {direction: MOVEMENT_NORTH, delta_line: -1, delta_column: 0},
          {direction: MOVEMENT_SOUTH, delta_line: 1, delta_column: 0},
          {direction: MOVEMENT_EAST, delta_line: 0, delta_column: 1},
          {direction: MOVEMENT_WEST, delta_line: 0, delta_column: -1}
      ].each do |possible_move|
        target_line = place_to_try[:target_line] + possible_move[:delta_line]
        target_column = place_to_try[:target_column] + possible_move[:delta_column]
        unless map[target_line].key?(target_column)
          places_to_try << {
              path: place_to_try[:path] + [possible_move[:direction]],
              target_line: target_line,
              target_column: target_column,
              amplifier: amplifier
          }
        end
      end
    end
  end
end

draw_map(map)

map[oxygen_system_line][oxygen_system_column] = -1
draw_map(map)
number_of_minutes = 0
while true
  number_of_minutes += 1
  at_least_one_location_filled = false
  map.each_pair do |target_line, line_locations|
    line_locations.each do |target_column, location_value|
      if location_value == RESULT_MOVED
        if ((map[target_line - 1][target_column] == - number_of_minutes) ||
            (map[target_line + 1][target_column] == - number_of_minutes) ||
            (map[target_line][target_column - 1] == - number_of_minutes) ||
            (map[target_line][target_column + 1] == - number_of_minutes)
        )
          map[target_line][target_column] = - number_of_minutes - 1
          at_least_one_location_filled = true
        end
      end
    end
  end
  p ""
  p number_of_minutes
  draw_map(map)
  unless at_least_one_location_filled
    p number_of_minutes - 1
    exit
  end
end
