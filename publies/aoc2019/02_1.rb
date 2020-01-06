def interpret_instruction(memory, instruction_pointer)
  opcode = memory[instruction_pointer]
  case opcode
  when 1 # add
    memory[memory[instruction_pointer + 3]] =
        (memory[memory[instruction_pointer + 1]] || 0) +
            (memory[memory[instruction_pointer + 2]] || 0)
    4
  when 2 # multiply
    memory[memory[instruction_pointer + 3]] =
        (memory[memory[instruction_pointer + 1]] || 0) *
            (memory[memory[instruction_pointer + 2]] || 0)
    4
  when 99
    nil
  else
    raise opcode.to_s
  end
end

def interpret_program(memory)
  instruction_pointer = 0
  while (delta = interpret_instruction(memory, instruction_pointer))
    instruction_pointer += delta
  end
  memory
end