require 'socket'

connection_index = 0

SOCKETS_TO_THING[server] = nil

class Operation
  # @param [Integer] byte
  # @param [Integer] index
  # @return [Integer]
  def process(byte, index)
    raise "Should not happen"
  end
end

class ReverseBits < Operation
  def process(byte, index)
    byte.to_s(2).rjust(8, '0').reverse.to_i(2)
    reversed = 0
    8.times do
      reversed = (reversed << 1) | (byte & 1)
      byte >>= 1
    end
    reversed
  end
end

class Xor < Operation
  # @param [Integer] value
  def initialize(value)
    @value = value
  end

  def process(byte, index) end
end

class XorPos < Operation
  def process(byte, index) end
end

class Add < Operation
  # @param [Integer] value
  def initialize(value)
    @value = value
  end

  def process(byte, index) end
end

class AddPos < Operation
  def process(byte, index) end
end

class Client
  # @param [Integer] connection_index
  # @param [TCPSocket] socket
  def initialize(connection_index, socket)
    @connection_index = connection_index
    @socket = socket
    @cypher = nil
    log("New connection")
    @client_index = 0
    @server_index = 0
  end

  # @param [String] message
  def log(message)
    STDOUT << "#{@connection_index} #{message}\n"
  end

  # @param [Array<Integer>] codepoints
  def extract_cypher(codepoints)
    @cyper = []
    current_position = 0
    loop do
      case codepoints[current_position]
      when 0
        return current_position + 1
      when 1
        @cypher << ReverseBits.new
        current_position += 1
      when 2
        @cypher << Xor.new(codepoints[current_position + 1])
        current_position += 1
      when 3
        @cypher << XorPos.new
        current_position += 1
      when 4
        @cypher << Add.new(codepoints[current_position + 1])
        current_position += 2
      when 5
        @cypher << AddPos.new
        current_position += 1
      else
        raise "Unexpected #{codepoints[current_position]} #{codepoints}"
      end
    end
  end

  # @param [Array<Integer>] codepoints
  def process_request(codepoints) end

  def process(content)
    if content.nil?
      log("client disconnected")
      @socket.close
      SOCKETS_TO_THING.delete(@socket)
    elsif @cypher.nil?
      codepoints = content.codepoints
      cypher_end = self.extract_cypher(codepoints)
      @server_index = cypher_end
      process_request(codepoints[cypher_end + 1..-1])
    else
      process_request(content.codepoints)
    end
  end
end

server = TCPServer.open(nil, 3002)

loop do
  read, _, _ = IO.select(SOCKETS_TO_THING.keys)
  read.each do |socket|
    if socket == server
      connection_index += 1
      client = server.accept
      SOCKETS_TO_THING[client] = Client.new(connection_index, client)
    else
      SOCKETS_TO_THING[socket].process(socket.recv(6000))
    end
  end
end
