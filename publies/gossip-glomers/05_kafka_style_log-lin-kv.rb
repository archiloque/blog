require_relative "message"

module LinKv
  LIN_KV_NODE_ID = "lin-kv"

  class KeyNotExistException < RuntimeError
  end

  # @return [void]
  def initialize_lin_kv
    @lin_kv_callbacks = {}
    @lin_kv_callbacks_mutex = Mutex.new

    add_source_handler(LIN_KV_NODE_ID) do |response|
      in_reply_to = response[:body][:in_reply_to]
      callback = @lin_kv_callbacks_mutex.synchronize do
        @lin_kv_callbacks.delete(in_reply_to)
      end
      if callback
        callback.call(response)
      else
        raise "Unexpected callback #{response}"
      end
    end
  end

  # @param [String] key
  # @return [void]
  def lin_kv_read(key:, &block)
    message_id = register_callback do |response|
      lin_kv_read_callback(response, &block)
    end
    send_message_raw(
      {
        src: @node_id,
        dest: LIN_KV_NODE_ID,
        body: {
          msg_id: message_id,
          type: :read,
          key: key
        }
      }
    )
  end

  # @param [String] key
  # @param [Object] from
  # @param [Object] to
  # @param [Boolean] create_if_not_exists
  # @return [Integer]
  def lin_kv_compare_and_swap(key:, from:, to:, create_if_not_exists:, &block)
    message_id = register_callback do |response|
      lin_kv_compare_and_swap_callback(response, &block)
    end
    send_message_raw(
      {
        src: @node_id,
        dest: LIN_KV_NODE_ID,
        body: {
          msg_id: message_id,
          type: :cas,
          key: key,
          from: from,
          to: to,
          create_if_not_exists: create_if_not_exists
        }
      }
    )
    message_id
  end

  private

  # @return [Integer]
  def register_callback(&block)
    unless block
      raise "No block !"
    end
    message_id = next_message_id
    @lin_kv_callbacks_mutex.synchronize do
      @lin_kv_callbacks[message_id] = lambda { |response| yield(response) }
    end
    message_id
  end

  # @param [Hash] response
  # @return [void]
  def lin_kv_read_callback(response, &block)
    if response[:body][:type] == "error"
      if response[:body][:text] == "key does not exist"
        block.call(KeyNotExistException)
      else
        raise "Unexpected exception #{response}"
      end
    elsif response[:body][:type] == "read_ok"
      block.call(response[:body][:value])
    else
      raise "Unexpected answer #{response}"
    end
  end

  # @param [Hash] response
  # @return [void]
  def lin_kv_write_callback(response, &block)
    if response[:body][:type] == "write_ok"
      block.call
    else
      raise "Unexpected answer #{response}"
    end
  end

  # @param [Hash] response
  # @return [void]
  def lin_kv_compare_and_swap_callback(response, &block)
    if response[:body][:type] == "cas_ok"
      block.call(true)
    elsif (response[:body][:type] == "error") && (response[:body][:code] == 22)
      block.call(false)
    else
      raise "Unexpected answer #{response}"
    end
  end
end
