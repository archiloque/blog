#!/usr/bin/env ruby

# https://fly.io/dist-sys/3a/
# https://fly.io/dist-sys/3b/
# https://fly.io/dist-sys/3c/
# https://fly.io/dist-sys/3d/
# https://fly.io/dist-sys/3e/
#
# Challenge #3a: Single-Node Broadcast
# echo -en "\033]1; 3a \007" ; RETRANSMIT_SLEEP=1000 LOG=true ./maelstrom test -w broadcast --bin ../03_broadcast/main.rb --node-count 1 --time-limit 20 --rate 10 --log-stderr
# Challenge #3b: Multi-Node Broadcast
# echo -en "\033]1; 3b \007" ; RETRANSMIT_SLEEP=1000 LOG=true ./maelstrom test -w broadcast --bin ../03_broadcast/main.rb --node-count 5 --time-limit 20 --rate 10 --log-stderr
# Challenge #3c: Fault Tolerant Broadcast
# echo -en "\033]1; 3c \007" ; RETRANSMIT_SLEEP=1000 LOG=true ./maelstrom test -w broadcast --bin ../03_broadcast/main.rb --node-count 5 --time-limit 20 --rate 10 --nemesis partition --log-stderr
# Challenge #3d: Efficient Broadcast, Part I
# echo -en "\033]1; 3d \007" ; BATCH_DELAY=30 RETRANSMIT_SLEEP=1000 LOG=true ./maelstrom test -w broadcast --bin ../03_broadcast/main.rb --node-count 25 --time-limit 20 --rate 100 --latency 100 --log-stderr
# Challenge #3e: Efficient Broadcast, Part II
# echo -en "\033]1; 3e \007" ; BATCH_DELAY=200 RETRANSMIT_SLEEP=1000 LOG=true ./maelstrom test -w broadcast --bin ../03_broadcast/main.rb --node-count 25 --time-limit 20 --rate 100 --latency 100 --log-stderr
#
require "json"
require "set"

class Main
  def initialize
    @current_message_id = 0
    @node_id = nil
    @nodes = nil
    @messages = Set.new
    @topology = nil
    @waiting_messages_by_nodes = Hash.new { |hash, key| hash[key] = {} }
    @log_lock = Mutex.new
    @send_message_lock = Mutex.new
    @waiting_messages_lock = Mutex.new
    @messages_lock = Mutex.new
    @messages_id_lock = Mutex.new
    @log = (ENV["LOG"] == "true")
    @broadcast_targets = {}
    @retransmit_sleep = (ENV["RETRANSMIT_SLEEP"] || "1000").to_i.to_f / 1000

    @batch_delay = (ENV["BATCH_DELAY"] || "100").to_i.to_f / 1000
    @batch_locks = Hash.new { |hash, key| hash[key] = Mutex.new }
    @batches_contents = Hash.new { |hash, key| hash[key] = [] }
    @batches_threads = {}
  end

  def run
    log("Started")
    loop do
      process_message($stdin.gets)
    end
  end

  private

  # @param [String] raw_request
  # @return [void]
  def process_message(raw_request)
    request = JSON.parse(raw_request.strip, symbolize_names: true)
    log("Received request [#{request}]")
    request_type = request[:body][:type]
    case request_type
    when "init"
      process_loop_init(request)
    when "broadcast"
      Thread.new do
        process_broadcast(request)
      end
    when "batch"
      Thread.new do
        process_batch(request)
      end
    when "batch_ok"
      process_batch_ok(request)
    when "read"
      process_read(request)
    when "topology"
      process_topology(request)
    else
      raise "Unknown type [#{request_type}] for message [#{request}]"
    end
  end

  # @return [Integer]
  def next_message_id
    @messages_id_lock.synchronize do
      @current_message_id += 1
    end
  end

  # @param [Hash] request
  # @param [Hash] response_body
  # @param [String] dest
  # @param [Integer] message_id
  # @return [void]
  def send_message(request:, response_body:, message_id:, dest: request[:src])
    send_message_raw(
      {
        src: @node_id,
        dest: dest,
        body: response_body.merge(
          {
            msg_id: message_id,
            in_reply_to: request[:body][:msg_id]
          }
        )
      }
    )
  end

  # @param [Hash] request
  # @return [void]
  def process_loop_init(request)
    @node_id = request[:body][:node_id]
    @nodes = request[:body][:node_ids]

    log("Node id is [#{@node_id}]")
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :init_ok
      }
    )
  end

  # @param [Hash] request
  # @return [void]
  def process_broadcast(request)
    # Confirm
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :broadcast_ok
      }
    )

    message = request[:body][:message]
    origin = request[:body][:origin] || @node_id
    received_message(message, origin)
  end

  # @param [Hash] request
  # @return [void]
  def process_batch(request)
    # Confirm
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :batch_ok
      }
    )
    request[:body][:content].each do |content|
      received_message(content[:message], content[:origin])
    end
  end

  def start_retransmit_to_nodes_thread
    Thread.new do
      loop do
        sleep(@retransmit_sleep)
        log("Retransmit thread wakes up after #{@retransmit_sleep}")
        nodes = @waiting_messages_lock.synchronize do
          @waiting_messages_by_nodes.keys.to_a
        end
        nodes.each do |node|
          retransmit_to_node(node)
        end
      end
    end
  end

  # @param [String] node
  # @return [void]
  def retransmit_to_node(node)
    waiting_messages_to_source_node = @waiting_messages_lock.synchronize do
      @waiting_messages_by_nodes[node].values.to_a
    end
    unless waiting_messages_to_source_node.empty?
      log("Broadcast again to [#{node}]")
      waiting_messages_to_source_node.each do |message_params|
        send_message_raw(message_params)
      end
    end
  end

  # @param [Hash] request
  # @return [void]
  def process_batch_ok(request)
    message_id = request[:body][:in_reply_to]
    source_node_id = request[:src]
    @waiting_messages_lock.synchronize do
      @waiting_messages_by_nodes[source_node_id].delete(message_id)
    end
  end

  # @param [Hash] request
  # @return [void]
  def process_read(request)
    messages = @messages_lock.synchronize do
      @messages.to_a
    end
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :read_ok,
        messages: messages
      }
    )
  end

  # @param [Hash] request
  # @return [void]
  def process_topology(request)
    @topology = request[:body][:topology].transform_keys(&:to_s)
    log("Topology is [#{@topology}]")
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :topology_ok
      }
    )

    @nodes.each do |starting_node|
      previous_reached_nodes = [starting_node]
      all_reached_nodes = Set.new(previous_reached_nodes)
      current_reached_nodes = nil
      until all_reached_nodes.length == @nodes.length
        current_reached_nodes = []
        previous_reached_nodes.each do |previous_reached_node|
          @topology[previous_reached_node].each do |new_node|
            if all_reached_nodes.add?(new_node)
              # It`'s a new node
              current_reached_nodes << new_node
            end
          end
        end
        previous_reached_nodes = current_reached_nodes
      end

      # The starting node will contact the fartest nodes
      @topology[starting_node].concat(current_reached_nodes)

      previous_reached_nodes = [starting_node]
      all_reached_nodes = Set.new(previous_reached_nodes)
      nodes_to_target = []
      until all_reached_nodes.length == @nodes.length
        current_reached_nodes = []
        previous_reached_nodes.each do |previous_reached_node|
          @topology[previous_reached_node].each do |new_node|
            if all_reached_nodes.add?(new_node)
              # It`'s a new node
              current_reached_nodes << new_node
              if previous_reached_node == @node_id
                nodes_to_target << new_node
              end
            end
          end
        end
        previous_reached_nodes = current_reached_nodes
      end
      @broadcast_targets[starting_node] = nodes_to_target
    end
    log("Broadcasts targets are [#{@broadcast_targets}]")
    start_retransmit_to_nodes_thread
  end

  # @param [Object] message
  # @return [void]
  def log(message)
    if @log
      log_message = "#{@node_id || "?"}-#{Thread.current.object_id} #{message}"
      @log_lock.synchronize do
        warn(log_message)
      end
    end
  end

  # @param [Hash] message
  # @return [void]
  def send_message_raw(message)
    response_json = message.to_json
    log("Send message [#{response_json}]")
    @send_message_lock.synchronize do
      $stdout << "#{response_json}\n"
      $stdout.flush
    end
  end

  # @param [String] origin
  # @param [String] target_node_id
  # @return [void]
  def send_batch_message(origin, target_node_id)
    sleep(@batch_delay)
    @batch_locks[target_node_id].synchronize do
      message_id = next_message_id
      message_body = {
        src: @node_id,
        dest: target_node_id,
        body: {
          type: :batch,
          origin: origin,
          msg_id: message_id,
          content: @batches_contents[target_node_id]
        }
      }
      send_message_raw(
        message_body
      )
      @waiting_messages_lock.synchronize do
        @waiting_messages_by_nodes[target_node_id][message_id] = message_body
      end
      @batches_contents[target_node_id] = []
      @batches_threads.delete(target_node_id)
    end
  end

  # @param [String] message
  # @param [String] origin
  def received_message(message, origin)
    new_message = @messages_lock.synchronize do
      @messages.add?(message)
    end

    if new_message
      log("New message #{message} with origin being #{origin} broadcasting it")
      @broadcast_targets[origin].each do |target_node_id|
        log("Will transmit message #{message} to #{target_node_id}")
        @batch_locks[target_node_id].synchronize do
          @batches_contents[target_node_id] << {
            message: message,
            origin: origin
          }
        end
        unless @batches_threads.key?(target_node_id)
          @batches_threads[target_node_id] = Thread.new do
            send_batch_message(origin, target_node_id)
          end
        end
      end
    end
  end
end

Main.new.run
