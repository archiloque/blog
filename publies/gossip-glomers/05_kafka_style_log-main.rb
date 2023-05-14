#!/usr/bin/env ruby

# https://fly.io/dist-sys/5a/
# https://fly.io/dist-sys/5b/
#
# Challenge #5a: Single-Node Kafka-Style Log
# LOG=true ./maelstrom test -w kafka --bin ../05_kafka_style_log/main.rb --node-count 1 --concurrency 2n --time-limit 20 --rate 1000 --log-stderr
# Challenge #5b: Multi-Node Kafka-Style Log
# LOG=true ./maelstrom test -w kafka --bin ../05_kafka_style_log/main.rb --node-count 2 --concurrency 2n --time-limit 20 --rate 1000 --log-stderr
#
require "json"
require "set"

require_relative "logging"
require_relative "loop"
require_relative "message"
require_relative "lin-kv"

class Main
  include Logging
  include Loop
  include Message
  include LinKv

  def initialize
    initialize_logging
    initialize_message
    initialize_loop
    initialize_lin_kv

    @logs = Hash.new { |hash, key| hash[key] = Log.new(self, key) }

    add_message_handler("send") do |request|
      process_send(request)
    end
    add_message_handler("poll") do |request|
      process_poll(request)
    end
    add_message_handler("commit_offsets") do |request|
      process_commit_offsets(request)
    end
    add_message_handler("list_committed_offsets") do |request|
      process_list_committed_offsets(request)
    end
  end

  private

  # @param [String] log_id
  # @return [void]
  def next_log_msg_id(log_id, &block)
    lin_kv_read(
      key: log_id,
    ) do |current_value|
      if current_value == KeyNotExistException
        lin_kv_compare_and_swap(
          key: log_id,
          from: -1,
          to: 0,
          create_if_not_exists: true,
        ) do |response|
          if response
            yield(0)
          else
            next_log_msg_id(log_id, &block)
          end
        end
      else
        msg_value = current_value + 1
        lin_kv_compare_and_swap(
          key: log_id,
          from: current_value,
          to: msg_value,
          create_if_not_exists: false
        ) do |response|
          if response
            yield(msg_value)
          else
            next_log_msg_id(log_id, &block)
          end
        end
      end
    end
  end

  # @param [Hash] request
  # @return [void]
  def process_send(request)
    log_id = request[:body][:key]

    if request[:body].key?(:x_msg_id)
      @logs[log_id.to_s].add_message(request[:body][:msg], request[:body][:x_msg_id])
    else
      next_log_msg_id(log_id) do |msg_id|
        @logs[log_id.to_s].add_message(request[:body][:msg], msg_id)
        send_message(
          request: request,
          message_id: next_message_id,
          response_body: {
            type: :send_ok,
            offset: msg_id,
          }
        )
        @nodes.each do |node_id|
          if node_id != @node_id
            send_message(
              dest: node_id,
              request: request,
              message_id: next_message_id,
              response_body: request[:body].merge(x_msg_id: msg_id)
            )
          end
        end
      end
    end
  end

  # @param [Hash] request
  # @return [void]
  def process_poll(request)
    msgs = {}
    request[:body][:offsets].each_pair do |log_id, starting_index|
      msgs[log_id] = @logs[log_id.to_s].poll(starting_index)
    end
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :poll_ok,
        msgs: msgs,
      }
    )
  end

  # @param [Hash] request
  # @return [void]
  def process_commit_offsets(request)
    request[:body][:offsets].each_pair do |log_id, offset|
      @logs[log_id.to_s].set_commit_offset(offset)
    end
    unless @nodes.include?(request[:src])
      send_message(
        request: request,
        message_id: next_message_id,
        response_body: {
          type: :commit_offsets_ok,
        }
      )
      @nodes.each do |node_id|
        if node_id != @node_id
          send_message(
            dest: node_id,
            request: request,
            message_id: next_message_id,
            response_body: request[:body]
          )
        end
      end
    end
  end

  # @param [Hash] request
  # @return [void]
  def process_list_committed_offsets(request)
    result = {}
    request[:body][:keys].each do |log_id|
      if @logs.key?(log_id.to_s)
        result[log_id] = @logs[log_id.to_s].commit_offset
      end
    end
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :list_committed_offsets_ok,
        offsets: result,
      }
    )
  end
end

class Log

  # @return [Integer]
  attr_reader :commit_offset

  # @param [String] id
  def initialize(main, id)
    @main = main
    @id = id
    @lock = Mutex.new
    @messages = {}
    @commit_offset = 0
  end

  # @param [Integer] message
  # @param [Integer] index
  # @return [void]
  def add_message(message, index)
    @lock.synchronize do
      @messages[index] = message
    end
  end

  # @param [Integer] starting_index
  # @return [Array<Array>]
  def poll(starting_index)
    @lock.synchronize do
      if @messages.empty?
        []
      else
        result_for_log = []
        starting_index.upto(@messages.keys.max) do |index|
          if @messages.key?(index)
            result_for_log << [index, @messages[index]]
          end
        end
        result_for_log
      end
    end
  end

  # @param [Integer] new_commit_offset
  # @return [void]
  def set_commit_offset(new_commit_offset)
    @lock.synchronize do
      if new_commit_offset > commit_offset
        @commit_offset = new_commit_offset
      end
    end
  end
end

Main.new.start_loop
