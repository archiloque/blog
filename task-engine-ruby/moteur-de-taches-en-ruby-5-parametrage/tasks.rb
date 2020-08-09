module TaskEngine
  module Tasks
    class WaitingTask
      PARAMETER_WAITING_TIME = 'waiting_time'

      # @param [Hash] parameters
      def initialize(parameters)
        sleep(parameters[PARAMETER_WAITING_TIME])
      end
    end
  end
end