require 'socket'

connection_index = 0
connection_index_mutex = Mutex.new

NAMES_BY_INDEX = []

COIN_FORMAT = "(7[a-zA-Z\\d]{25,34})"
START_FORMAT = /\A#{COIN_FORMAT} .*\n\z/
END_FORMAT = /\A.* #{COIN_FORMAT}\n\z/
ONLY_FORMAT = /\A#{COIN_FORMAT}\n\z/
MIDDLE_FORMAT = /.*? #{COIN_FORMAT} .*\n\z/

TONY_ADDRESS = "7YWHMfk9JZe0LM0g1ZauHuiSxhI"

# @param [string] message
# @return [String]
def replace_coin(message)
  result = message
  if (m = START_FORMAT.match(result))
    result = result.gsub(m[1], TONY_ADDRESS)
  end
  if (m = END_FORMAT.match(result))
    result = result.gsub(m[1], TONY_ADDRESS)
  end
  if (m = ONLY_FORMAT.match(result))
    result = result.gsub(m[1], TONY_ADDRESS)
  end
  index = 0
  while (m = MIDDLE_FORMAT.match(result, index))
    result = result.gsub(m[1], TONY_ADDRESS)
    index = m.byteoffset(1)[0] + TONY_ADDRESS.length - 1
  end
  result
end

# @param [Socket] client_connection
# @param [Integer] connection_index
def handle(client_connection, connection_index)
  STDOUT << "#{connection_index} Connection started\n"
  should_close = false
  upstream_connection = TCPSocket.new('chat.protohackers.com', 16963)
  upstream_buffer = ""
  client_buffer = ""

  until should_close do
    read, _, _ = IO.select([client_connection, upstream_connection])
    if read.include?(upstream_connection)
      STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Upstream will read\n"
      upstream_content = upstream_connection.recv_nonblock(1048)
      STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Upstream read\n"
      if upstream_content.nil?
        STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Upstream disconnected\n"
        should_close = true
      else
        STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Upstream received #{upstream_content.length} bytes\n"
        upstream_buffer << upstream_content
        until (line_end = upstream_buffer.index("\n")).nil?
          message = upstream_buffer[0..line_end]
          upstream_buffer = upstream_buffer[line_end + 1..-1]
          replaced = replace_coin(message)
          if should_close
            STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Should close\n"
          else
            STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Upstream sending to client {#{message.strip}} -> {#{replaced.strip}}\n"
            client_connection.write(replaced)
          end
        end
      end
    end

    if read.include?(client_connection)
      STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Client will read\n"
      client_content = client_connection.recv_nonblock(1048)
      STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Client read\n"
      if client_content.nil?
        STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Client disconnected\n"
        should_close = true
      else
        STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Client received #{client_content.length} bytes\n"
        client_buffer << client_content
        until (line_end = client_buffer.index("\n")).nil?
          message = client_buffer[0..line_end]
          unless NAMES_BY_INDEX[connection_index]
            NAMES_BY_INDEX[connection_index] = message.strip
          end
          client_buffer = client_buffer[line_end + 1..-1]
          replaced = replace_coin(message)
          STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Client sending to upstream {#{message.strip}} -> {#{replaced.strip}}\n"
          if should_close
            STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Client upstream should close\n"
          else
            upstream_connection.write(replaced)
          end
        end
      end
    end
  end
  STDOUT << "#{connection_index} #{NAMES_BY_INDEX[connection_index]} Connection closing\n"
  client_connection.close
  upstream_connection.close
end

STDOUT << "Starting server\n"
Socket.tcp_server_loop(3002) do |connection|
  connection_connection_index = 0
  connection_index_mutex.synchronize do
    connection_connection_index = connection_index
    connection_index += 1
  end
  Thread.new do
    handle(connection, connection_connection_index)
  end
end
