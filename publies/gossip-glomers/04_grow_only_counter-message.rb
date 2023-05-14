module Message
  # @return void
  def initialize_message
    @current_message_id = 0
    @messages_id_lock = Mutex.new
    @messages_lock = Mutex.new
    @send_message_lock = Mutex.new
  end

  # @return [Integer]
  def next_message_id
    @messages_id_lock.synchronize do
      @current_message_id += 1
    end
  end

  # @param [Hash] message
  # @return [void]
  def send_message_raw(message)
    message_json = message.to_json
    log("Send message [#{message_json}]")
    @send_message_lock.synchronize do
      $stdout << "#{message_json}\n"
      $stdout.flush
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
end
