# @param [Array<Integer>] memory
# @param [Integer] instruction_pointer
# @param [String] instruction
# @param [Integer] parameter_index
# @return [Integer]
def value(memory, instruction_pointer, instruction, parameter_index)
  instruction_mode = instruction[-(3 + parameter_index)]
  p "  mode for #{parameter_index} is #{(instruction_mode == '0') ? 'position' : 'immediate'}"
  parameter_value = memory[instruction_pointer + parameter_index + 1]
  p "  parameter for #{parameter_index} is #{parameter_value}"
  case instruction_mode
  when '0' # position
    memory[parameter_value]
  when '1' # immediate
    parameter_value
  else
    raise instruction_mode
  end
end

# @param [Array<Integer>] memory
# @param [Integer] instruction_pointer
# @param [Array<Integer>] io
# @return [Integer|nil]
def interpret_instruction(memory, instruction_pointer, io)
  instruction = sprintf("%05d", memory[instruction_pointer])
  p ''
  p "instruction #{instruction}"
  opcode = instruction[-2..-1]
  case opcode
  when '01' # add
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    c = memory[instruction_pointer + 3]
    p "add #{a} & #{b} to #{c}"
    memory[c] = a + b
    4
  when '02' # multiply
    a = value(memory, instruction_pointer, instruction, 0)
    b = value(memory, instruction_pointer, instruction, 1)
    c = memory[instruction_pointer + 3]
    p "multiply #{a} & #{b} to #{c}"
    memory[c] = a * b
    4
  when '03' # input
    a = memory[instruction_pointer + 1]
    p "input at #{a}"
    memory[a] = io.shift
    2
  when '04' # output
    a = value(memory, instruction_pointer, instruction, 0)
    p "output from #{a}"
    io << a
    2
  when '99'
    nil
  else
    raise opcode
  end
end

# @param [Array<Integer>] memory
# @param [Array<Integer>] io
def interpret_program(memory, io)
  instruction_pointer = 0
  while (delta = interpret_instruction(memory, instruction_pointer, io))
    instruction_pointer += delta
  end
  memory
end
