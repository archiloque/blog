require 'socket'
require 'set'

connection_index = 0

PACK_SKIP_8_BIT = "x"
PACK_8_BIT = "C"
PACK_16_BIT = "n"
PACK_32_BIT = "N"
PACK_CHAR = "a"

ACTION_ERROR = 16
ACTION_WANT_HEARTBEAT = 64
ACTION_HEARTBEAT = 65
ACTION_I_AM_CAMERA = 128
ACTION_I_AM_DISPATCHER = 129
ACTION_PLATE = 32
ACTION_TICKET = 33

Observation = Struct.new('Observation', :timestamp, :mile)

Ticket = Struct.new('Ticket', :plate, :mile1, :timestamp1, :mile2, :timestamp2, :speed)

# @type [Hash<String, Set<Integer>]
TICKETS_DAYS_BY_CAR = Hash.new { |hash, key| hash[key] = Set.new }

class Road
  # @param [Integer] index
  def initialize(index)
    @index = index
    @observations_by_car = Hash.new { |hash, key| hash[key] = [] }
    @speed_limit = nil
    @dispatchers = []
    @waiting_tickets = []
  end

  # @param [String] message
  def log(message)
    STDOUT << "Road #{@index} with limit #{@speed_limit} #{message}\n"
  end

  def set_speed_limit(speed_limit)
    if @speed_limit.nil?
      log("setting speed limit #{speed_limit}")
      @speed_limit = speed_limit
    end
  end

  # @param [Dispatcher] dispatcher
  def add_dispatcher(dispatcher)
    if @dispatchers.empty?
      unless @waiting_tickets.empty?
        log("sending #{@waiting_tickets.length} waiting tickets to new dispatcher")
        dispatcher.send_tickets(@index, @waiting_tickets)
        @waiting_tickets = []
      end
    end
    @dispatchers << dispatcher
  end

  def remove_dispatcher(dispatcher)
    @dispatchers.delete(dispatcher)
  end

  # @param [String] plate
  # @param [Integer] mile
  # @param [Integer] timestamp
  def add_observation(plate, mile, timestamp)
    log("add observation plate #{plate} mile #{mile} timestamp #{timestamp}")
    if @speed_limit.nil?
      puts "Observation before speed limit"
      exit(1)
    end
    # @type [Array<Observation>]
    observations_for_car = @observations_by_car[plate]
    # @type [Observation?]
    before_observation = observations_for_car.filter { |e| e.timestamp < timestamp }.sort_by { |e| e.timestamp }.last
    # @type [Observation?]
    after_observation = observations_for_car.filter { |e| e.timestamp > timestamp }.sort_by { |e| e.timestamp }.first

    # @type [Ticket]
    ticket = nil
    # @type [Set<Integer>]
    tickets_for_car = TICKETS_DAYS_BY_CAR[plate]
    observation_day = timestamp / 86400

    unless before_observation.nil?
      before_day = before_observation.timestamp / 86400
      distance = (mile - before_observation.mile).abs
      duration = (timestamp - before_observation.timestamp).to_f / 3600
      speed = distance / duration
      log("before observation for #{plate} from #{before_observation.mile} to #{mile} from #{before_observation.timestamp} #{before_day} to #{timestamp} #{observation_day} is #{distance} in #{duration} speed is #{speed}")
      if speed > (@speed_limit + 0.25)
        possible_ticket = Ticket.new(
          plate,
          before_observation.mile,
          before_observation.timestamp,
          mile,
          timestamp,
          (speed * 100).to_i
        )
        new_ticket = true
        (before_day..observation_day).each do |day|
          if tickets_for_car.include?(day)
            log("for #{plate} already a ticket for day #{day}")
            new_ticket = false
          end
        end
        if new_ticket
          (before_day..observation_day).each do |day|
            tickets_for_car.add(day)
          end
          ticket = possible_ticket
        end
      end
    end
    unless after_observation.nil?
      after_day = after_observation.timestamp / 86400
      distance = (after_observation.mile - mile).abs
      duration = (after_observation.timestamp - timestamp).to_f / 3600
      speed = distance / duration
      log("after observation for #{plate} from #{mile} to #{after_observation.mile} from #{timestamp} #{observation_day} to #{after_observation.timestamp} #{after_day} is #{distance} in #{duration} speed is #{speed}")
      if speed > (@speed_limit + 0.25)
        possible_ticket = Ticket.new(
          plate,
          mile,
          timestamp,
          after_observation.mile,
          after_observation.timestamp,
          (speed * 100).to_i,
        )
        new_ticket = true
        (observation_day..after_day).each do |day|
          if tickets_for_car.include?(day)
            log("for #{plate} already a ticket for day #{day}")
            new_ticket = false
          end
        end
        if new_ticket && (ticket.nil?)
          (observation_day..after_day).each do |day|
            tickets_for_car.add(day)
          end
          ticket = possible_ticket
        end
      end
    end
    if ticket
      if @dispatchers.empty?
        log("storing ticket for later")
        @waiting_tickets << ticket
      else
        log("sending ticket")
        @dispatchers.first.send_tickets(@index, [ticket])
      end
    end
    @observations_by_car[plate] << Observation.new(timestamp, mile)
  end

  # @param [String] plate
  # @return [Array[Observation]]
  def for_car(plate)
    if @speed_limit.nil?
      puts "Observation before speed limit for road"
      exit(1)
    end
    @data[plate]
  end
end

class World
  def initialize
    @data = {}
  end

  # @param [Integer] road
  # @return [Road]
  def road(road)
    result = @data[road]
    if result.nil?
      result = Road.new(road)
      @data[road] = result
    end
    result
  end
end

WORLD = World.new

class Thing
  attr_reader :connection_index, :socket
  attr_accessor :buffer

  # @param [Integer] connection_index
  # @param [TCPSocket] socket
  # @param [String] buffer
  def initialize(connection_index, socket, buffer)
    @connection_index = connection_index
    @socket = socket
    @buffer = buffer
    @heartbeat = nil
  end

  # @param [String] message
  # @param [Boolean] print_buffer
  def log(message, print_buffer = true)
    buffer_content = print_buffer ? " |#{buffer.chars.map { |c| c.ord }.join(' ')}|" : ""
    STDOUT << "#{@connection_index} #{self.class.name} #{message}#{buffer_content}\n"
  end

  # @param [Integer] tick
  def heartbeat(tick)
    if @socket.closed? || @heartbeat.nil? || (@heartbeat == 0)
    else
      if (tick % @heartbeat) == 0
        log("heartbeat #{tick}", false)
        @socket.write([ACTION_HEARTBEAT].pack(PACK_8_BIT))
      end
    end
  end

  # @param [String | nil] content
  def process(content)
    if content.nil?
      log("client disconnected")
      @socket.close
      SOCKETS_TO_THING.delete(@socket)
      after_delete
    else
      buffer << content
      if buffer.length > 0
        action = buffer.unpack(PACK_8_BIT)[0]
        log("action #{action}")
        case action
        when ACTION_WANT_HEARTBEAT
          unless @heartbeat.nil?
            error
          end
          if @buffer.length >= 5
            @heartbeat = @buffer.unpack("#{PACK_8_BIT}#{PACK_32_BIT}")[1]
            self.buffer = @buffer[5..-1]
          end
        else
          process_content(action)
        end
      end
    end
  end

  def after_delete

  end

  ERROR_MESSAGE = [ACTION_ERROR, 0].pack("#{PACK_8_BIT}#{PACK_8_BIT}")

  def error
    log("error")
    @socket.write(ERROR_MESSAGE)
    @socket.close
    SOCKETS_TO_THING.delete(@socket)
  end

  # @param [Integer] action
  def process_content(action)
    raise "To be implemented"
  end

end

class Dispatcher < Thing
  # @param [Unknown] unknown_thing

  def initialize(unknown_thing)
    super(unknown_thing.connection_index, unknown_thing.socket, unknown_thing.buffer)
    @setuped = false
    process("")
  end

  def process_content(action)
    if @setuped
      error
    else
      case action
      when ACTION_I_AM_DISPATCHER
        roads_size = buffer.unpack("#{PACK_SKIP_8_BIT}#{PACK_8_BIT}")[0]
        min_buffer_size = 2 + (roads_size * 2)
        if buffer.length >= min_buffer_size
          @roads = buffer.unpack("#{PACK_SKIP_8_BIT}2#{PACK_16_BIT}#{roads_size}")
          log("#{roads_size} roads : #{@roads.join(', ')}")
          self.buffer = buffer[min_buffer_size..-1]
          @setuped = true
          @roads.each do |road|
            WORLD.road(road).add_dispatcher(self)
          end
          process("")
        else
          log("not enough data for setup #{buffer.length} < #{min_buffer_size}")
        end
      else
        error
      end
    end
  end

  # @param [Array<Ticket>] tickets
  # @param [Integer] road
  def send_tickets(road, tickets)
    tickets.each do |ticket|
      ticket_message = [ACTION_TICKET, ticket.plate.length, ticket.plate, road, ticket.mile1, ticket.timestamp1, ticket.mile2, ticket.timestamp2, ticket.speed]
                         .pack("#{PACK_8_BIT}#{PACK_8_BIT}#{PACK_CHAR}*#{PACK_16_BIT}#{PACK_16_BIT}#{PACK_32_BIT}#{PACK_16_BIT}#{PACK_32_BIT}#{PACK_16_BIT}")
      log("send ticket #{ticket} for road [#{road} #{ticket_message.chars.map { |c| c.ord }.join(' ')}]", false)
      @socket.write(ticket_message)
    end
  end

  def after_delete
    @roads.each do |road|
      WORLD.road(road).remove_dispatcher(self)
    end
  end
end

class Camera < Thing
  # @param [Unknown] unknown_thing

  def initialize(unknown_thing)
    super(unknown_thing.connection_index, unknown_thing.socket, unknown_thing.buffer)
    @setuped = false
    process("")
  end

  SETUP_BUFFER_LENGTH = 1 + (2 * 3)
  PLATE_MINIMUM_LENGTH = 1 + 1 + 4

  def process_content(action)
    if @setuped
      case action
      when ACTION_PLATE
        if buffer.length >= PLATE_MINIMUM_LENGTH
          plate_size = buffer.unpack("#{PACK_SKIP_8_BIT}#{PACK_8_BIT}")[0]
          expected_plate_data_size = (plate_size + PLATE_MINIMUM_LENGTH)
          if buffer.length >= expected_plate_data_size
            plate_data = buffer.unpack("#{PACK_SKIP_8_BIT}2#{PACK_CHAR}#{plate_size}#{PACK_32_BIT}")
            plate = plate_data[0]
            timestamp = plate_data[1]
            log("plate #{plate} timestamp #{timestamp}", false)
            self.buffer = buffer[expected_plate_data_size..-1]
            WORLD.road(@road).add_observation(plate, @mile, timestamp)
            process("")
          else
            log("not enough data for plate #{buffer.length} < #{expected_plate_data_size}", false)
          end
        else
          log("not enough data for plate #{buffer.length} < #{PLATE_MINIMUM_LENGTH}", false)
        end
      else
        error
      end
    else
      case action
      when ACTION_I_AM_CAMERA
        if buffer.length >= SETUP_BUFFER_LENGTH
          @setuped = true
          values = buffer.unpack("#{PACK_SKIP_8_BIT}#{PACK_16_BIT}3")
          @road = values[0]
          @mile = values[1]
          @limit = values[2]
          log("mile #{@mile} limit #{@limit}")
          self.buffer = buffer[SETUP_BUFFER_LENGTH..-1]
          WORLD.road(@road).set_speed_limit(@limit)
          process("")
        else
          log("not enough data for setup #{buffer.length} < #{SETUP_BUFFER_LENGTH}", false)
        end
      else
        error
      end
    end
  end

  def log(message, print_buffer = true)
    super("#{@road} #{message}", print_buffer)
  end
end

class Unknown < Thing
  # @param [Integer] connection_index
  # @param [TCPSocket] socket
  def initialize(connection_index, socket)
    super(connection_index, socket, "")
    log("new connection")
  end

  def process_content(action)
    case action
    when ACTION_I_AM_CAMERA
      log("is a camera")
      SOCKETS_TO_THING[@socket] = Camera.new(self)
    when ACTION_I_AM_DISPATCHER
      log("is a dispatcher")
      SOCKETS_TO_THING[@socket] = Dispatcher.new(self)
    else
      error
    end
  end
end

STDOUT << "Starting server\n"
SOCKETS_TO_THING = {}
server = TCPServer.open(nil, 3002)

Thread.new do
  tick = 0
  loop do
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
    SOCKETS_TO_THING.values.each do |thing|
      if thing
        thing.heartbeat(tick)
      end
    end
    tick += 1
    end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
    sleep(0.1 - (end_time - start_time))
  end
end

SOCKETS_TO_THING[server] = nil
loop do
  read, _, _ = IO.select(SOCKETS_TO_THING.keys)
  read.each do |socket|
    if socket == server
      connection_index += 1
      client = server.accept
      SOCKETS_TO_THING[client] = Unknown.new(connection_index, client)
    else
      SOCKETS_TO_THING[socket].process(socket.recv(1048))
    end
  end
end

