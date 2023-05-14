#!/usr/bin/env ruby

# https://fly.io/dist-sys/6a/
# https://fly.io/dist-sys/6b/
# https://fly.io/dist-sys/6c/
#
# Challenge #6a: Single-Node, Totally-Available Transactions
# LOG=true ./maelstrom test -w txn-rw-register --bin ../06_totally_available_transactions/main.rb --node-count 1 --time-limit 20 --rate 1000 --concurrency 2n --consistency-models read-uncommitted --availability total --log-stderr
# Challenge #6b: Totally-Available, Read Uncommitted Transactions
# LOG=true ./maelstrom test -w txn-rw-register --bin ../06_totally_available_transactions/main.rb --node-count 2 --concurrency 2n --time-limit 20 --rate 1000 --consistency-models read-uncommitted --log-stderr
# LOG=true ./maelstrom test -w txn-rw-register --bin ../06_totally_available_transactions/main.rb --node-count 2 --concurrency 2n --time-limit 20 --rate 1000 --consistency-models read-uncommitted --availability total --nemesis partition --log-stderr
# Challenge #6c: Totally-Available, Read Committed Transactions
# LOG=true ./maelstrom test -w txn-rw-register --bin ../06_totally_available_transactions/main.rb --node-count 2 --concurrency 2n --time-limit 20 --rate 1000 --consistency-models read-committed --availability total –-nemesis partition --log-stderr
require "json"
require "set"

require_relative "logging"
require_relative "loop"
require_relative "message"

class Main
  include Logging
  include Loop
  include Message

  def initialize
    initialize_logging
    initialize_message
    initialize_loop
    @values = {}
    @lock = Mutex.new
    @nodes_mutex = Hash.new { |hash, key| hash[key] = Mutex.new }
    @to_transmit_per_node = Hash.new { |hash, key| hash[key] = {} }
    @transmit_sleep = (ENV["RETRANSMIT_SLEEP"] || "100").to_i.to_f / 1000
    @failure_rate = 0.1

    add_message_handler("txn") do |request|
      process_txn(request)
    end
    add_message_handler("txn_inner") do |request|
      process_txn_inner(request)
    end
    add_message_handler("txn_inner_ok") do |request|
      process_txn_inner_ok(request)
    end

    add_after_init_hook do
      Thread.new do
        loop do
          transmit_values
          sleep(@transmit_sleep)
        end
      end
    end
  end

  private

  # @param [Hash] request
  # @return [void]
  def process_txn(request)
    changes = {}
    result = request[:body][:txn].map do |operation|
      operation_type, key, value = operation
      case operation_type
      when "r"
        ["r", key, changes[key] || @values[key]]
      when "w"
        changes[key] = value
        ["w", key, value]
      else
        raise "Unknown type [#{operation_type}] for message [#{request}]"
      end
    end

    @lock.synchronize do
      @values.merge!(changes)
    end

    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :txn_ok,
        txn: result,
      }
    )

    @nodes.each do |node|
      if node != @node_id
        @nodes_mutex[node].synchronize do
          request[:body][:txn].each do |operation|
            operation_type, key, value = operation
            if operation_type == "w"
              @to_transmit_per_node[node][key] = value
            end
          end
        end
      end
    end
  end

  # @param [Hash] request
  # @return [void]
  def process_txn_inner(request)
    @lock.synchronize do
      @values.merge!(request[:body][:txn])
    end
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :txn_inner_ok,
        txn: request[:body][:txn],
      }
    )
  end

  # @param [Hash] request
  # @return [void]
  def process_txn_inner_ok(request)
    node = request[:src]
    @nodes_mutex[node].synchronize do
      request[:body][:txn].each_pair do |key, value|
        if @to_transmit_per_node[node][key] == value
          @to_transmit_per_node.delete(key)
        end
      end
    end
  end

  def transmit_values
    @nodes.each do |node|
      if node != @node_id
        @nodes_mutex[node].synchronize do
          unless @to_transmit_per_node[node].empty?
            send_message_raw(
              src: @node_id,
              dest: node,
              body: {
                msg_id: next_message_id,
                type: :txn_inner,
                txn: @to_transmit_per_node[node],
              }
            )
          end
        end
      end
    end
  end
end

Main.new.start_loop
