# @param [Array<Integer>] memory
# @param [Integer] instruction_pointer
# @param [String] instruction
# @param [Integer] parameter_index
# @return [Integer]
def value(memory, instruction_pointer, instruction, parameter_index)
  instruction_mode = instruction[-(3 + parameter_index)]
  parameter_value = memory[instruction_pointer + parameter_index + 1]
  case instruction_mode
  when `'0`' # position
    memory[parameter_value]
  when `'1`' # immediate
    parameter_value
  else
    raise instruction_mode
  end
end

def print_instruction(
    memory,
    instruction_pointer,
    instruction,
    opcode,
    number_of_params)
  STDOUT << "#{opcode} #{instruction} #{memory[instruction_pointer + 1, number_of_params].join(`', `')}".ljust(40)
end

# @param [Array<Integer>] memory
# @param [Integer] instruction_pointer
# @param [Array<Integer>] io
# @return [Integer|nil]
def interpret_instruction(memory, instruction_pointer, io)
  instruction = sprintf("%05d", memory[instruction_pointer])
  opcode = instruction[-2..-1]
  case opcode
  when `'01`' # add
    print_instruction(memory, instruction_pointer, instruction, `'add`', 3)
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    c = memory[instruction_pointer + 3]
    STDOUT << "Store #{a} + #{b} at #{c}\n"
    memory[c] = a + b
    instruction_pointer + 4
  when `'02`' # multiply
    print_instruction(memory, instruction_pointer, instruction, `'multiply`', 3)
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    c = memory[instruction_pointer + 3]
    STDOUT << "Store #{a} * #{b} at #{c}\n"
    memory[c] = a * b
    instruction_pointer + 4
  when `'03`' # input
    print_instruction(memory, instruction_pointer, instruction, `'input`', 1)
    a = memory[instruction_pointer + 1]
    STDOUT << "Input at #{a}\n"
    memory[a] = io.shift
    instruction_pointer + 2
  when `'04`' # output
    print_instruction(memory, instruction_pointer, instruction, `'output`', 1)
    a = value(memory, instruction_pointer, instruction, 0)
    STDOUT << "Output #{a}\n"
    io << a
    instruction_pointer + 2
  when `'05`' # jump-if-true
    print_instruction(memory, instruction_pointer, instruction, `'jump-if-true`', 2)
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    if a != 0
      STDOUT << "Set instruction pointer to #{b} (#{a}, #{b})\n"
      b
    else
      STDOUT << "Do nothing\n"
      instruction_pointer + 3
    end
  when `'06`' # jump-if-false
    print_instruction(memory, instruction_pointer, instruction, `'jump-if-false`', 2)
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    if a == 0
      STDOUT << "Set instruction pointer to #{b} (#{a}, #{b})\n"
      b
    else
      STDOUT << "Do nothing\n"
      instruction_pointer + 3
    end
  when `'07`' # less-than
    print_instruction(memory, instruction_pointer, instruction, `'less-than`', 3)
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    c = memory[instruction_pointer + 3]
    value = (a < b) ? 1 : 0
    STDOUT << "Set #{value} at #{c} (#{a} < #{b})\n"
    memory[c] = value
    instruction_pointer + 4
  when `'08`' # equals
    print_instruction(memory, instruction_pointer, instruction, `'equals`', 3)
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    c = memory[instruction_pointer + 3]
    value = (a == b) ? 1 : 0
    STDOUT << "Set #{value} at #{c} (#{a} == #{b})\n"
    memory[c] = value
    instruction_pointer + 4
  when `'99`'
    print_instruction(memory, instruction_pointer, instruction, `'exit`', 0)
    STDOUT << "Exit\n"
    nil
  else
    raise opcode
  end
end

# @param [Array<Integer>] memory
# @param [Array<Integer>] io
# @return [Array<Integer>]
def interpret_program(memory, io)
  STDOUT << "\n"
  instruction_pointer = 0
  while (instruction_pointer = interpret_instruction(memory, instruction_pointer, io))
  end
  io
end
