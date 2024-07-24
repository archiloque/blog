require 'socket'

database = {}
socket = UDPSocket.new
socket.bind("", 3002)
loop do
  text, addr = socket.recvfrom(1000)
  STDOUT << "From #{addr} received [#{text}]\n"
  equal_index = text.index('=')
  if equal_index.nil?
    if text == 'version'
      value = "Nya"
    else
      value = database[text]
    end
    if value.nil?
      STDOUT << "No value\n"
    else
      message = "#{text}=#{value}"[0..1000]
      STDOUT << "Sending [#{message}] to #{addr[3]} #{addr[1]}\n"
      socket.send(message, 0, addr[3], addr[1])
    end
  else
    key = text[0...equal_index]
    value = text[equal_index + 1..-1]
    STDOUT << "Storing #{value} at [#{key}]\n"
    database[key] = value
  end
end