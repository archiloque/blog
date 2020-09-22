module TaskEngine
  module Tasks
    class WaitingTask
      PARAMETER_WAITING_TIME = 'waiting_time'

      # @param [Hash] parameters
      # @return [Hash, nil]
      def execute(parameters)
        sleep(parameters[PARAMETER_WAITING_TIME])
        nil
      end
    end

    class FailingTask
      # @param [Hash] parameters
      # @return [Hash, nil]
      def execute(parameters)
        1 / 0
      end
    end

    class FailingNotRetryTask
      include TaskEngine::NoRetryTask

      # @param [Hash] parameters
      # @return [Hash, nil]
      def execute(parameters)
        1 / 0
      end
    end

    class FailingNotRetryExceptionTask
      class FailingNotRetryTaskException < Exception
        include TaskEngine::NoRetryException
      end

      # @param [Hash] parameters
      # @return [Hash, nil]
      def execute(parameters)
        raise FailingNotRetryTaskException.new('Oh no')
      end
    end
  end
end