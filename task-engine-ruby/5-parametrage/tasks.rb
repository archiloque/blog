module TaskEngine
  module Tasks
    class WaitingTask
      PARAMETER_WAITING_TIME = 'waiting_time'

      # @param [Hash] parameters
      # @return [Hash, nil]
      def execute(parameters)
        sleep(parameters[PARAMETER_WAITING_TIME])
      end
    end
  end
end