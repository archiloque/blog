require 'socket'

server = TCPServer.new(3002)

connection_index = 0
connection_index_mutex = Mutex.new

# @param [Socket] connection
# @param [Integer] connection_index
def handle(connection, connection_index)
  STDOUT << "#{connection_index} Connection started\n"
  values = {}
  unprocessed_bytes = ""
  loop do
    request = connection.recv(1048)
    if request.nil?
      STDOUT << "#{connection_index} Received EOF\n"
      connection.close
      return
    end
    STDOUT << "#{connection_index} Received #{request.length} byte(s) [#{request}]\n"
    unprocessed_bytes << request
    while unprocessed_bytes.length >= 9
      message = unprocessed_bytes[0..8]
      unprocessed_bytes = unprocessed_bytes[9..-1]
      parsed_message = message.unpack("al>l>")
      STDOUT << "#{connection_index} Process a message [#{message}] [#{message.unpack("c*").join(',')}] #{parsed_message}\n"
      type = parsed_message[0]
      case type
      when 'I'
        timestamp = parsed_message[1]
        value = parsed_message[2]
        values[timestamp] = value
        STDOUT << "#{connection_index} Insert #{timestamp} #{value}\n"
      when 'Q'
        min_time = parsed_message[1].to_i
        max_time = parsed_message[2].to_i
        found_values = []
        if max_time < min_time
          result = 0
        else
          values.each_pair do |timestamp, value|
            if (timestamp >= min_time) && (timestamp <= max_time)
              found_values << value
            end
          end
          STDOUT << "#{connection_index} Request found values #{found_values.join(',')}\n"
          if found_values.empty?
            result = 0
          else
            result = (found_values.sum / found_values.length).to_i
          end
        end
        result_pack = [result].pack("l>")
        STDOUT << "#{connection_index} Request result is #{result} [#{result_pack}]\n"
        connection.write(result_pack)
      else
        STDOUT << "#{connection_index} Bad type\n"
        connection.close
        return
      end
    end
  end
end

STDOUT << "Starting server\n"
Socket.accept_loop(server) do |connection|
  connection_connection_index = 0
  connection_index_mutex.synchronize do
    connection_connection_index = connection_index
    connection_index += 1
  end
  Thread.new do
    handle(connection, connection_connection_index)
  end
end
