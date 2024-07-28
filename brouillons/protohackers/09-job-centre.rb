require 'socket'

connection_index = 0

SOCKETS_TO_THING = {}

server = TCPServer.open(nil, 3002)
SOCKETS_TO_THING[server] = nil

class

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
