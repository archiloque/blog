LOG_INFO = false

class Amplifier

  STATUS_EXIT = :exit
  STATUS_NEED_INPUT = :need_input
  STATUS_CAN_CONTINUE = :can_continue

  attr_reader :status

  # @param [Integer] index
  # @param [Array<Integer>] memory
  # @param [Array<Integer>] io_in
  def initialize(index, memory, io_in)
    @index = index
    @memory = memory
    @io_in = io_in
    @instruction_pointer = 0
  end

  # @param [Array<Integer>] input
  # @return [Array<Integer>|nil]
  def resume(input)
    io_out = []
    @io_in.concat(input)
    if LOG_INFO
      STDOUT << "\nResume amplifier #{@index} with pointer at #{@instruction_pointer} with input #{@io_in}\n"
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

  # @param [Array<Integer>] io_out
  # @return [Symbol] STATUS_EXIT, STATUS_NEED_INPUT or STATUS_CAN_CONTINUE
  def interpret_instruction(io_out)
    instruction = sprintf("%05d", @memory[@instruction_pointer])
    opcode = instruction[-2..-1]
    case opcode
    when '01' # add
      print_instruction(instruction, 'add', 3)
      a = value(instruction, 0)
      b = value(instruction, 1)
      c = @memory[@instruction_pointer + 3]
      log_instruction("Store (#{a} + #{b}) at #{c}")
      @memory[c] = a + b
      @instruction_pointer += 4
      STATUS_CAN_CONTINUE
    when '02' # multiply
      print_instruction(instruction, 'multiply', 3)
      a = value(instruction, 0)
      b = value(instruction, 1)
      c = @memory[@instruction_pointer + 3]
      log_instruction("Store (#{a} * #{b}) at #{c}")
      @memory[c] = a * b
      @instruction_pointer += 4
      STATUS_CAN_CONTINUE
    when '03' # input
      print_instruction(instruction, 'input', 1)
      if @io_in.empty?
        return STATUS_NEED_INPUT
      end
      a = @memory[@instruction_pointer + 1]
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
      c = @memory[@instruction_pointer + 3]
      value = (a < b) ? 1 : 0
      log_instruction("Set #{value} at #{c} (#{a} < #{b})")
      @memory[c] = value
      @instruction_pointer += 4
      STATUS_CAN_CONTINUE
    when '08' # equals
      print_instruction(instruction, 'equals', 3)
      a = value(instruction, 0)
      b = value(instruction, 1)
      c = @memory[@instruction_pointer + 3]
      value = (a == b) ? 1 : 0
      log_instruction("Set #{value} at #{c} (#{a} == #{b})")
      @memory[c] = value
      @instruction_pointer += 4
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
  def value(instruction, parameter_index)
    instruction_mode = instruction[-(3 + parameter_index)]
    parameter_value = @memory[@instruction_pointer + parameter_index + 1]
    case instruction_mode
    when '0' # position
      @memory[parameter_value]
    when '1' # immediate
      parameter_value
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

# @param [Array<Integer>] memory
# @param [Array<Integer>] phase_settings
# @return [Integer]
def test_combination(memory, phase_settings)
  amplifiers = [
      Amplifier.new(0, memory.dup, [phase_settings[0]]),
      Amplifier.new(1, memory.dup, [phase_settings[1]]),
      Amplifier.new(2, memory.dup, [phase_settings[2]]),
      Amplifier.new(3, memory.dup, [phase_settings[3]]),
      Amplifier.new(4, memory.dup, [phase_settings[4]])
  ]

  io = [0]
  current_amplifier_index = 0
  last_thruster_signal = nil
  while amplifiers[current_amplifier_index].status != Amplifier::STATUS_EXIT
    io = amplifiers[current_amplifier_index].resume(io)
    if current_amplifier_index == 4
      last_thruster_signal = io.first
      current_amplifier_index = 0
      if LOG_INFO
        STDOUT << "\n"
      end
    else
      current_amplifier_index += 1
    end
  end
  last_thruster_signal
end

POSSIBLE_SETTINGS = [5, 6, 7, 8, 9]

# @param [Array<Integer>] memory
# @return [Hash]
def max_combination(memory)
  max_thruster = 0
  max_sequence = []
  POSSIBLE_SETTINGS.each do |s1|
    (POSSIBLE_SETTINGS - [s1]).each do |s2|
      (POSSIBLE_SETTINGS - [s1, s2]).each do |s3|
        (POSSIBLE_SETTINGS - [s1, s2, s3]).each do |s4|
          (POSSIBLE_SETTINGS - [s1, s2, s3, s4]).each do |s5|
            phase_settings = [s1, s2, s3, s4, s5]
            result = test_combination(memory, phase_settings)
            if LOG_INFO
              STDOUT << "\n"
            end
            if result > max_thruster
              max_thruster = result
              max_sequence = phase_settings
            end
          end
        end
      end
    end
  end
  {max_thruster: max_thruster, max_sequence: max_sequence}
end
