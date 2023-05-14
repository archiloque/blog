#!/usr/bin/env ruby

# https://fly.io/dist-sys/2/
#
# Challenge #2: Unique ID Generation
# echo -en "\033]1; 2 \007" ; ./maelstrom test -w unique-ids --bin ../02_unique_id_generation/main.rb --time-limit 30 --rate 1000 --node-count 3 --availability total --nemesis partition --log-stderr

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
    @current_message_id += 1
    message = JSON.parse(raw_message, symbolize_names: true)
    message_body = message[:body]
    message_type = message_body[:type]
    response_body = case message_type
                    when "init"
                      init(message_body)
                    when "generate"
                      generate(message_body)
                    else
                      raise "Unknown type [#{message_type}]"
                    end
    response =
      {
        src: @node_id,
        dest: message[:src],
        body: response_body.merge(
          {
            msg_id: @current_message_id,
            in_reply_to: message_body[:msg_id]
          }
        )
      }
    log("Created response [#{response}]")
    $stdout << "#{response.to_json}\n"
    $stdout.flush
  end

  # @param [Hash] message_body
  # @return [Hash]
  def init(message_body)
    @node_id = message_body[:node_id]
    log("Node id is [#{@node_id}]")
    {
      type: :init_ok
    }
  end

  # @param [Hash] _message_body
  # @return [Hash]
  def generate(_message_body)
    {
      type: :generate_ok,
      id: "#{@node_id}-#{@current_message_id}"
    }
  end

  # @param [Object] message
  # @return [void]
  def log(message)
    warn(message)
  end
end

Main.new.run
