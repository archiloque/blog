#!/usr/bin/env ruby

# https://fly.io/dist-sys/4/
#
# Challenge #4: Grow-Only Counter
# LOG=true ./maelstrom test -w g-counter --bin ../04_grow_only_counter/main.rb --node-count 1 --rate 100 --time-limit 20 --log-stderr
# LOG=true ./maelstrom test -w g-counter --bin ../04_grow_only_counter/main.rb --node-count 3 --rate 100 --time-limit 20 --log-stderr
# LOG=true ./maelstrom test -w g-counter --bin ../04_grow_only_counter/main.rb --node-count 3 --rate 100 --time-limit 20 --nemesis partition --log-stderr
#
require "json"
require "set"

require_relative "logging"
require_relative "loop"
require_relative "message"
require_relative "seq-kv"

class Main
  include Logging
  include Loop
  include Message
  include SeqKv

  VALUE_KEY = "value"

  def initialize
    initialize_logging
    initialize_message
    initialize_loop
    initialize_seq_kv
    @waiting_deltas = {}
    @delta_mutex = Mutex.new
    @update_mutex = false
    @transmit_sleep = (ENV["RETRANSMIT_SLEEP"] || "100").to_i.to_f / 1000
    @read_sleep = (ENV["READ_SLEEP"] || "2000").to_i.to_f / 1000

    add_message_handler("read") do |request|
      process_read(request)
    end
    add_message_handler("add") do |request|
      process_add(request)
    end

    add_after_init_hook do
      seq_kv_compare_and_swap(
        key: "value",
        from: 0,
        to: 0,
        create_if_not_exists: true,
      ) do |_response|
        @last_known_value = 0
        Thread.new do
          loop do
            send_updated_value
            sleep(@transmit_sleep)
          end
        end
      end
      Thread.new do
        loop do
          read_value
          sleep(@read_sleep)
        end
      end

    end
  end

  private

  def read_value
    seq_kv_read(
      key: VALUE_KEY,
    ) do |value|
      log("New known value: #{value}")
      @last_known_value = value
      if block_given?
        yield(value)
      end
    end
  end

  # @param [Hash] request
  # @return [void]
  def process_read(request)
    send_message(
      request: request,
      message_id: next_message_id,
      response_body: {
        type: :read_ok,
        value: @last_known_value + @waiting_deltas.values.sum,
      }
    )
  end

  # @param [Hash] request
  # @return [void]
  def process_add(request)
    message_id = next_message_id
    send_message(
      request: request,
      message_id: message_id,
      response_body: {
        type: :add_ok,
      }
    )

    delta = request[:body][:delta]
    @waiting_deltas[message_id] = delta
  end

  def send_updated_value
    log("send_updated_value: starting")
    if @update_mutex
      log("send_updated_value: lock already in place, doing nothing")
    else
      @update_mutex = true
      waiting_deltas_dup = @waiting_deltas.dup
      if waiting_deltas_dup.empty?
        @update_mutex = false
        log("send_updated_value: nothing to do so going to sleep")
      else
        read_value do |current_value|
          @last_known_value = current_value
          waiting_deltas_dup = @waiting_deltas.dup
          if waiting_deltas_dup.empty?
            @update_mutex = false
            log("send_updated_value: nothing to do so going to sleep")
          else
            log("send_updated_value: will try to update value")
            target_value = waiting_deltas_dup.values.sum + @last_known_value
            seq_kv_compare_and_swap(
              key: VALUE_KEY,
              from: current_value,
              to: target_value,
              create_if_not_exists: false,
            ) do |result|
              if result
                log("send_updated_value: operation is OK")
                waiting_deltas_dup.keys.each do |key|
                  @waiting_deltas.delete(key)
                end
              else
                log("send_updated_value: operation is KO")
              end
              log("send_updated_value: unlock")
              @update_mutex = false
            end
          end
        end
      end
    end
  end
end

Main.new.start_loop
