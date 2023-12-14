LOG_INFO = false

class Amplifier

  STATUS_EXIT = :exit
  STATUS_NEED_INPUT = :need_input
  STATUS_CAN_CONTINUE = :can_continue

  attr_reader :status

  # @param [Array<Integer>] memory
  # @param [Array<Integer>] io_in
  def initialize(memory, io_in)
    @memory = memory
    @io_in = io_in
    @instruction_pointer = 0
    @relative_base = 0
    @status = :can_continue
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

COLOR_BLACK = 0
COLOR_WHITE = 1

current_line = 0
current_column = 0
current_direction = :up
hull = Hash.new { |hash, key| hash[key] = {} }
hull[0][0] = COLOR_WHITE

memory = IO.read('input.txt').split(',').map(&:to_i)

amplifier = Amplifier.new(
    memory,
    [])
until amplifier.status == Amplifier::STATUS_EXIT
  out = amplifier.resume([hull[current_line][current_column] || COLOR_BLACK])
  amplifier.status == Amplifier::STATUS_NEED_INPUT
  hull[current_line][current_column] = out[0]
  case out[1]
  when 0
    current_direction = {
        up: :left,
        left: :down,
        down: :right,
        right: :up
    }[current_direction]
  when 1
    current_direction = {
        up: :right,
        right: :down,
        down: :left,
        left: :up
    }[current_direction]
  else
    raise out[1].to_s
  end
  case current_direction
  when :up
    current_line -= 1
  when :down
    current_line += 1
  when :right
    current_column += 1
  when :left
    current_column -= 1
  else
    raise current_direction
  end
end

def read_char
  begin
    system("stty raw -echo")
    str = STDIN.getc
  ensure
    system("stty -raw echo")
  end
  str
end

def print_info(screen, score)
  0.upto((output.length / 3) - 1) do |i|
    x = output[3 * i]
    y = output[(3 * i) + 1]
    id = output[(3 * i) + 2]
    if (x == -1) && (y == 0)
      score = id
    else
      unless screen[y]
        screen[y] = []
      end
      screen[y][x] = id
    end
  end

  STDOUT << "#{screen.collect { |l| l.join('') }.join("\n")}\n#{score}\n"
end

memory = IO.read('input.txt').split(',').map(&:to_i)
memory[0] = 2
amplifier = Amplifier.new(
    memory,
    [])

screen = []
current_score = -1
max_score = -1

next_direction = 0
while true
  output = amplifier.resume([next_direction])
  0.upto((output.length / 3) - 1) do |i|
    x = output[3 * i]
    y = output[(3 * i) + 1]
    id = output[(3 * i) + 2]
    if (x == -1) && (y == 0)
      current_score = id
      if current_score > max_score
        max_score = current_score
      end
    else
      unless screen[y]
        screen[y] = []
      end
      screen[y][x] = id
    end
  end
  STDOUT << "\e[H\e[2J"
  STDOUT << "#{screen.collect { |l| l.join('').gsub('0', ' ') }.join("\n")}\n\n#{current_score}\n#{max_score}"
  ball_column = screen.find { |l| l.include?(4) }.index(4)
  paddle_column = screen.find { |l| l.include?(3) }.index(3)
  if ball_column < paddle_column
    next_direction = -1
  elsif paddle_column < ball_column
    next_direction = 1
  else
    next_direction = 0
  end
  sleep(0.01)
end
