require 'socket'

connection_index = 0

SOCKETS_TO_THING = {}

class Operation
  # @param [Integer] byte
  # @param [Integer] index
  # @return [Integer]
  def process(byte, index)
    raise "Should not happen"
  end
end

class ReverseBits < Operation

  VALUES = [0, 128, 64, 192, 32, 160, 96, 224, 16, 144, 80, 208, 48, 176, 112, 240, 8, 136, 72, 200, 40, 168, 104, 232, 24, 152, 88, 216, 56, 184, 120, 248, 4, 132, 68, 196, 36, 164, 100, 228, 20, 148, 84, 212, 52, 180, 116, 244, 12, 140, 76, 204, 44, 172, 108, 236, 28, 156, 92, 220, 60, 188, 124, 252, 2, 130, 66, 194, 34, 162, 98, 226, 18, 146, 82, 210, 50, 178, 114, 242, 10, 138, 74, 202, 42, 170, 106, 234, 26, 154, 90, 218, 58, 186, 122, 250, 6, 134, 70, 198, 38, 166, 102, 230, 22, 150, 86, 214, 54, 182, 118, 246, 14, 142, 78, 206, 46, 174, 110, 238, 30, 158, 94, 222, 62, 190, 126, 254, 1, 129, 65, 193, 33, 161, 97, 225, 17, 145, 81, 209, 49, 177, 113, 241, 9, 137, 73, 201, 41, 169, 105, 233, 25, 153, 89, 217, 57, 185, 121, 249, 5, 133, 69, 197, 37, 165, 101, 229, 21, 149, 85, 213, 53, 181, 117, 245, 13, 141, 77, 205, 45, 173, 109, 237, 29, 157, 93, 221, 61, 189, 125, 253, 3, 131, 67, 195, 35, 163, 99, 227, 19, 147, 83, 211, 51, 179, 115, 243, 11, 139, 75, 203, 43, 171, 107, 235, 27, 155, 91, 219, 59, 187, 123, 251, 7, 135, 71, 199, 39, 167, 103, 231, 23, 151, 87, 215, 55, 183, 119, 247, 15, 143, 79, 207, 47, 175, 111, 239, 31, 159, 95, 223, 63, 191, 127, 255]

  def process(byte, index)
    VALUES[byte]
  end

  alias :unprocess :process

  def to_s
    "ReverseBits"
  end
end

class Xor < Operation
  # @param [Integer] value
  def initialize(value)
    @value = value
  end

  def process(byte, index)
    @value ^ byte
  end

  alias :unprocess :process

  def to_s
    "Xor(#{@value})"
  end
end

class XorPos < Operation
  def process(byte, index)
    (byte ^ index) % 256
  end

  alias :unprocess :process

  def to_s
    "XorPos"
  end

end

class Add < Operation
  # @param [Integer] value
  def initialize(value)
    @value = value
  end

  def process(byte, index)
    (@value + byte) % 256
  end

  def unprocess(byte, index)
    (byte - @value) % 256
  end

  def to_s
    "Add(#{@value})"
  end
end

class AddPos < Operation
  def process(byte, index)
    (byte + index) % 256
  end

  def unprocess(byte, index)
    (byte - index) % 256
  end

  def to_s
    "AddPos"
  end
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
    @decoded_content = ""
    @current_request_start = 0
  end

  # @param [String] message
  def log(message)
    STDOUT << "#{@connection_index} #{message}\n"
  end

  # @param [Array<Integer>] content
  def extract_cypher(content)
    @cypher = []
    current_position = 0
    loop do
      case content[current_position]
      when 0
        log("Cypher: #{@cypher.join(', ')}")
        return current_position + 1
      when 1
        @cypher << ReverseBits.new
        current_position += 1
      when 2
        @cypher << Xor.new(content[current_position + 1])
        current_position += 2
      when 3
        @cypher << XorPos.new
        current_position += 1
      when 4
        @cypher << Add.new(content[current_position + 1])
        current_position += 2
      when 5
        @cypher << AddPos.new
        current_position += 1
      else
        raise "Unexpected #{content[current_position]} #{content}"
      end
    end
  end

  ITEM_REGEX = /\A(?<value>\d+)x .+\z/

  # @param [Array<Integer>] v
  def to_hex(v)
    "[#{v.map { |c| c.to_s(16) }.join(',')}]"
  end

  # @param [String] content
  def process_request(content)
    log("process request [#{content}]")
    items = content.split(',')
    items_by_value = {}
    items.each do |item|
      value = ITEM_REGEX.match(item)[:value].to_i
      items_by_value[value] = item
    end
    highest_item = "#{items_by_value[items_by_value.keys.max]}\n"
    log("highest item [#{highest_item}]")
    encoded_item = highest_item.unpack('C*').map do |c|
      @cypher.each do |operation|
        c = operation.process(c, @client_index)
      end
      @client_index += 1
      c
    end
    log("for #{to_hex(highest_item.unpack('C*')) } sending #{to_hex(encoded_item)}")
    @socket.write(encoded_item.pack('C*'))
  end

  # @param [Array<Integer>] content
  def process_content(content)
    if content.empty?
      return
    end
    initial_server_index = @server_index
    decoded_content = content.map do |c|
      @cypher.reverse.each do |operation|
        c = operation.unprocess(c, @server_index)
      end
      @server_index += 1
      c
    end
    if content == decoded_content
      log("no change in cyphering #{content} #{decoded_content}")
      @socket.close
      SOCKETS_TO_THING.delete(@socket)
      return
    end
    decoded_content_string = decoded_content.pack('C*')
    @decoded_content << decoded_content_string
    log("process_content started at #{initial_server_index}: #{to_hex(content)}, decoded: #{to_hex(decoded_content)}, string: [#{decoded_content_string}] [#{@decoded_content}]")
    loop do
      next_line_end = @decoded_content.index("\n", @current_request_start)
      if next_line_end.nil?
        return
      end
      log("line end found at #{next_line_end}")
      request = @decoded_content[@current_request_start...next_line_end]
      process_request(request)
      @current_request_start = next_line_end + 1
    end
  end

  def process(content)
    if content.nil?
      log("client disconnected")
      @socket.close
      SOCKETS_TO_THING.delete(@socket)
    elsif @cypher.nil?
      content_as_int = content.unpack('C*')
      log("process #{content_as_int}")
      cypher_size = self.extract_cypher(content_as_int)
      @server_index = 0
      process_content(content_as_int[cypher_size..-1])
    else
      content_as_int = content.unpack('C*')
      log("process #{content_as_int}")
      process_content(content_as_int)
    end
  end
end

unless ARGV.empty?
  content = ARGV[0].split(', ').map { |c| c.to_i() }.pack('C*')
  client = Client.new(1, nil)
  client.process(content)
end

server = TCPServer.open(nil, 3002)
SOCKETS_TO_THING[server] = nil

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
