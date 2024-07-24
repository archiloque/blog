require 'socket'

server = TCPServer.new(3002)

connection_index = 0
connection_index_mutex = Mutex.new

# @param [Socket] connection
# @param [Integer] connection_index
def handle(connection, connection_index)
  STDOUT << "#{connection_index} Connection started\n"
  loop do
    request = connection.recv(1048)
    if request.nil?
      STDOUT << "#{connection_index} Received EOF\n"
      connection.close
      STDOUT << "#{connection_index} Connection closed\n"
      return
    else
      STDOUT << "#{connection_index} Received content of #{request.length} bytes\n"
      connection.write(request)
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
