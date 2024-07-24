require 'socket'
require 'set'

# @type [Hash<String, Session>]
SESSIONS = {}

class Ack

  attr_reader :timestamp, :position, :packet

  def initialize(packet)
    @timestamp = Process.clock_gettime(Process::CLOCK_MONOTONIC, :second)
    @packet = packet
  end
end

class Session
  # @param [String] ip_address
  # @param [Integer] port
  # @param [Integer] session_id
  def initialize(ip_address, port, session_id)
    @ip_address = ip_address
    @port = port
    @session_id = session_id
    # @type [Array<String|nil>]
    @content = []
    @last_message_start = 0
    @waiting_acks = {}
    @max_ack_received = -1
  end

  # @return [String]
  def ack_packet
    if @content.empty?
      packet = "/ack/#{@session_id}/0/"
    else
      first_nil_position = @content.index(nil)
      if first_nil_position.nil?
        packet = "/ack/#{@session_id}/0/#{@content.length}/"
      else
        packet = "/ack/#{@session_id}/0/#{first_nil_position}/"
      end
    end
    log("Send ack [#{packet}]")
    packet
  end

  def send_data_packets
    new_message_start = @last_message_start
    @last_message_start.upto(@content.length - 1) do |index|
      current_char = @content[index]
      if current_char.nil?
        @last_message_start = new_message_start
        return
      elsif current_char == "\n"
        log("Found line end #{index}")
        initial_data = @content[new_message_start...index]
        packet_data = initial_data.map do |c|
          case c
          when '/'
            '\\/'
          when '\\'
            '\\\\'
          else
            c
          end
        end.reverse
        packet_data << "\n"
        log("Initial data packet [#{initial_data.join('')}]")
        packet_start_index = new_message_start
        packet_data.each_slice(950) do |data_slice|
          if @waiting_acks.key?(packet_start_index)
            log("Already sent packet")
          else
            packet = "/data/#{@session_id}/#{packet_start_index}/#{data_slice.join('')}/"
            log("Send data packet [#{packet}]")
            @waiting_acks[packet_start_index] = Ack.new(packet)
            SOCKET.send(packet, 0, @ip_address, @port)
          end
          packet_start_index += data_slice.length
        end
        new_message_start = index + 1
      end
      @last_message_start = new_message_start
    end
  end

  # @param [Integer] position
  # @param [String] data
  def received_data(position, data)
    log("Received data #{position} [#{data}]")
    escaped_data = data.gsub("\\\\", "\\").gsub("\\/", "/")
    @content[position, escaped_data.length] = escaped_data.chars
    SOCKET.send(ack_packet, 0, @ip_address, @port)
    send_data_packets
  end

  def received_ack(position)
    if position > @last_message_start
      log("Ack misbehaving ack #{position} #{@last_message_start}")
      SESSIONS.delete(@session_id)
    elsif position == @last_message_start
      @max_ack_received = position
      log("Final ack #{position} #{@last_message_start}")
      @waiting_acks[position] = nil
    elsif @waiting_acks.key?(position)
      if position > @max_ack_received
        @max_ack_received = position
      end
      @waiting_acks[position] = nil
      log("Received ack #{position} #{@last_message_start}")
    else
      log("Resending packets because of ack #{position}")
      @last_message_start = position
      send_data_packets
    end
  end

  # @param [Integer] current_time
  def heartbeat(current_time)
    @waiting_acks.keys.each do |position|
      ack = @waiting_acks[position]
      if (position < @max_ack_received) && (!ack.nil?)
        @waiting_acks[position] = nil
      end
      unless ack.nil?
        delta = (current_time - ack.timestamp)
        log("Heartbeat #{position} delta #{position} #{delta}")
        if delta == 0
        elsif delta >= 60
          log("Heartbeat #{position} timeout")
          SESSIONS.delete(@session_id)
          return
        elsif delta % 3 == 0
          log("Heartbeat #{position} resending packet [#{ack.packet}]")
          SOCKET.send(ack.packet, 0, @ip_address, @port)
        end
      end
    end
  end

  def log(message)
    STDOUT << "#{@session_id} #{message.gsub("\n", "|")}\n"
  end
end

CONNECT_REGEX = /\A\/connect\/(?<session_id>\d+)\/\z/
CLOSE_REGEX = /\A\/close\/(?<session_id>\d+)\/\z/
ACK_REGEX = /\A\/ack\/(?<session_id>\d+)\/(?<position>\d+)\/\z/m
DATA_REGEX = /\A\/data\/(?<session_id>\d+)\/(?<position>\d+)\/(?<data>.+)\/\z/m

def log(message)
  STDOUT << "#{message.gsub("\n", "|")}\n"
end

Thread.new do
  loop do
    STDOUT << "Heartbeat\n"
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
    start_time_s = start_time.to_i
    SESSIONS.values.each do |session|
      session.heartbeat(start_time_s)
    end
    end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
    sleep(1.0 - (end_time - start_time))
  end
end

SOCKET = UDPSocket.new
SOCKET.bind("", 3002)
loop do
  text, addr = SOCKET.recvfrom(2000)
  port = addr[1]
  ip_address = addr[3]
  # log("From #{ip_address} #{port} received [#{text}]")
  if text.length <= 1000
    if (m = CONNECT_REGEX.match(text))
      session_id = m[:session_id].to_i
      if session_id <= 2147483648
        if SESSIONS.key(session_id)
          log('Existing session')
        else
          log("#{session_id} New session")
          session = Session.new(ip_address, port, session_id)
          SESSIONS[session_id] = session
        end
        SOCKET.send("/ack/#{session_id}/0/", 0, ip_address, port)
      else
        log("#{session_id} Bad session id")
      end
    elsif (m = CLOSE_REGEX.match(text))
      session_id = m[:session_id].to_i
      if session_id <= 2147483648
        log("#{session_id} Close session")
        SESSIONS.delete(session_id)
        SOCKET.send("/close/#{session_id}/", 0, ip_address, port)
      else
        log("#{session_id} Bad session id")
      end
    elsif (m = ACK_REGEX.match(text))
      session_id = m[:session_id].to_i
      if session_id <= 2147483648
        if (session = SESSIONS[session_id])
          session.received_ack(m[:position].to_i)
        else
          log("#{session_id} No opened session to receive the ack")
          SOCKET.send("/close/#{session_id}/", 0, ip_address, port)
        end
      else
        log("#{session_id} Bad session id")
      end
    elsif (m = DATA_REGEX.match(text))
      session_id = m[:session_id].to_i
      if session_id <= 2147483648
        if (session = SESSIONS[session_id])
          position = m[:position].to_i
          data = m[:data]
          session.received_data(position, data)
        else
          log("#{session_id} No opened session to receive data")
          SOCKET.send("/close/#{session_id}/", 0, ip_address, port)
        end
      else
        log("#{session_id} Bad session id")
      end
    else
      log("Bad text [#{text}]")
    end
  else
    log("Text too long [#{text}]")
  end
end
