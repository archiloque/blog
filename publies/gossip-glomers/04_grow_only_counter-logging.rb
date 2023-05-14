module Logging
  # @return void
  def initialize_logging
    @log = (ENV["LOG"] == "true")
    @log_lock = Mutex.new
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
end
