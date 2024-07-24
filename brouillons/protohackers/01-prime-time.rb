require 'json'
require 'prime'
require 'socket'

server = TCPServer.new(3002)

connection_index = 0
connection_index_mutex = Mutex.new

# @param [Socket] connection
# @param [Integer] connection_index
def handle_error(connection, connection_index)
  STDOUT << "#{connection_index} Handle error\n"
  connection.write("")
  connection.close
end

# @param [Socket] connection
# @param [Integer] connection_index
def handle(connection, connection_index)
  STDOUT << "#{connection_index} Connection started\n"
  loop do
    request = connection.gets
    if request.nil?
      STDOUT << "#{connection_index} Received EOF\n"
      connection.close
      STDOUT << "#{connection_index} Connection closed\n"
      return
    end
    STDOUT << "#{connection_index} Received content of #{request.length} bytes [#{request}]\n"
    begin
      parsed_request = JSON.parse(request)
      if parsed_request['method'] != "isPrime"
        handle_error(connection, connection_index)
        return
      end
      possible_number = parsed_request['number']
      STDOUT << "#{connection_index} Number is #{possible_number}\n"
      if possible_number.nil?
        handle_error(connection, connection_index)
        return
      end
      if possible_number.is_a?(Integer)
        number = Integer(possible_number)
        is_prime = Prime.prime?(number)
        STDOUT << "#{connection_index} Number is #{is_prime} prime\n"
        connection.write("#{JSON.generate({ "method": "isPrime", "prime": is_prime })}\n")
      elsif possible_number.is_a? Float
        STDOUT << "#{connection_index} Number is a float\n"
        connection.write("#{JSON.generate({ "method": "isPrime", "prime": false })}\n")
      else
        STDOUT << "#{connection_index} Number is invalid\n"
        handle_error(connection, connection_index)
        return
      end
    rescue JSON::ParserError
      handle_error(connection, connection_index)
      return
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
