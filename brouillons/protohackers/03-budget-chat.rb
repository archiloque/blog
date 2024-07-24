require 'socket'

server = TCPServer.new(3002)

connection_index = 0
connection_index_mutex = Mutex.new

connected_users = {}
broadcast_mutex = Mutex.new

NAME_REGEX = /\A([a-zA-Z\d]+)\z/

# @param [Socket] connection
# @param [Integer] connection_index
# @param [Hash<String,Socket>] connected_users
# @param [Mutex] broadcast_mutex
def handle(connection, connection_index, connected_users, broadcast_mutex)

  STDOUT << "#{connection_index} Connection started\n"
  connection.write("Name please?\n")
  user_name = connection.gets
  if user_name.nil?
    STDOUT << "#{connection_index} Name: received EOF\n"
    connection.write('Bad name')
    connection.close
    return
  end
  user_name.strip!
  unless NAME_REGEX.match(user_name)
    STDOUT << "#{connection_index} Name: received bad name [#{user_name}]\n"
    connection.write('Bad name')
    connection.close
    return
  end
  STDOUT << "#{connection_index} Name is #{user_name}\n"
  message_to_user = "* People: #{connected_users.keys.join(', ')}\n"
  STDOUT << "#{connection_index} #{message_to_user}"
  connection.write(message_to_user)
  message_to_users = "* [#{user_name}] joined\n"
  broadcast_mutex.synchronize do
    connected_users.each_pair do |name, socket|
      STDOUT << "#{connection_index} #{name} #{message_to_users}"
      socket.write(message_to_users)
    end
    connected_users[user_name] = connection
  end

  current_content = ""
  loop do
    new_content = connection.recv(1048)
    STDOUT << "#{connection_index} Received [#{new_content}]\n"
    if new_content.nil?
      message_to_users = "* [#{user_name}] left\n"
      broadcast_mutex.synchronize do
        connected_users.delete(user_name)
        connected_users.each_pair do |name, socket|
          STDOUT << "#{connection_index} #{name} #{message_to_users}"
          socket.write(message_to_users)
        end
      end
      connection.close
      return
    end

    current_content << new_content
    until (end_of_message_index = current_content.index("\n")).nil?
      current_message = current_content[0..end_of_message_index]
      current_content = current_message[end_of_message_index + 1..-1]
      message_to_users = "[#{user_name}] #{current_message}"
      broadcast_mutex.synchronize do
        connected_users.each_pair do |name, socket|
          if name != user_name
            STDOUT << "#{connection_index} #{name} #{message_to_users}"
            socket.write(message_to_users)
          end
        end
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
    handle(connection, connection_connection_index, connected_users, broadcast_mutex)
  end
end
