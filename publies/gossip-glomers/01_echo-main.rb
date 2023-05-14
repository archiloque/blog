#!/usr/bin/env ruby

# https://fly.io/dist-sys/1/
#
# Challenge #1: Echo
# echo -en "\033]1; 1 \007" ; ./maelstrom test -w echo --bin ../01_echo/main.rb  --node-count 1 --time-limit 10  --log-stderr

require "json"

class Main
  def initialize
    @current_message_id = 0
    @node_id = nil
  end

  def run
    log("Started")
    loop do
      process_message($stdin.gets)
    end
  end

  private

  # @param [String] raw_message
  # @return [void]
  def process_message(raw_message)
    log("Received message [#{raw_message}]")
    message = JSON.parse(raw_message, symbolize_names: true)
    message_body = message[:body]
    message_type = message_body[:type]
    case message_type
    when "init"
      response_body = init(message)
    when "echo"
      response_body = echo(message)
    else
      raise "Unknown type [#{message_type}]"
    end
    response =
      {
        src: @node_id,
        dest: message[:src],
        body: response_body
      }
    log("Created response [#{response}]")
    $stdout << "#{response.to_json}\n"
    $stdout.flush
  end

  # @param [Hash] message_body
  # @return [Hash]
  def init(message_body)
    @node_id = message_body[:node_id]
    {
      type: :init_ok,
      in_reply_to: message_body[:msg_id]
    }
  end

  # @param [Hash] message_body
  # @return [Hash]
  def echo(message_body)
    @current_message_id += 1
    message_body.merge(
      type: :echo_ok,
      msg_id: @current_message_id,
      in_reply_to: message_body[:msg_id]
    )
  end

  # @param [Object] message
  # @return [void]
  def log(message)
    warn(message)
  end
end

Main.new.run
