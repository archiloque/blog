module Loop
  # @return [void]
  def initialize_loop
    @node_id = nil
    @waiting_messages_lock = Mutex.new
    @messages_types_handlers = {}
    @messages_sources_handlers = {}

    @after_init_hooks = []

    add_message_handler("init") do |request|
      process_loop_init(request)
    end
  end

  # @param [Proc] block
  # @return [void]
  def add_after_init_hook(&block)
    @after_init_hooks << block
  end

  # @param [String] message_type
  # @param [Proc] block
  # @return [void]
  def add_message_handler(message_type, &block)
    if @messages_types_handlers.key?(message_type)
      raise "A type handler already exists for [#{message_type}]"
    else
      @messages_types_handlers[message_type] = block
    end
  end

  # @param [String] message_source
  # @param [Proc] block
  # @return [void]
  def add_source_handler(message_source, &block)
    if @messages_sources_handlers.key?(message_source)
      raise "A source handler already exists for [#{message_source}]"
    else
      @messages_sources_handlers[message_source] = block
    end
  end

  # @return [void]
  def start_loop
    log("Start loop")
    loop do
      process_message($stdin.gets)
    end
  end

  # @param [String] raw_request
  # @return [void]
  def process_message(raw_request)
    request = JSON.parse(raw_request.strip, symbolize_names: true)
    log("Received message [#{request}]")
    request_type = request[:body][:type]
    request_source = request[:src]
    handler = @messages_types_handlers[request_type] || @messages_sources_handlers[request_source]
    if handler
      handler.call(request)
    else
      raise "Unhanded message [#{request}]"
    end
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
    @after_init_hooks.each do |hook|
      hook.call
    end
  end
end
