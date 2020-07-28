require 'date'
require 'logger'

module TaskEngine

  WORKERS_NUMBER = 5
  MILLISECONDS_IN_A_DAY = 24 * 60 * 60 * 1000
  LOGGER = Logger.new(STDOUT)
  
  class Engine
    def initialize
      LOGGER.info("Starting engine")
      0.upto(WORKERS_NUMBER - 1) do |worker_index|
        Worker.new(worker_index)
      end
      sleep
    end
  end

  class Worker

    # @param [Integer] worker_index
    def initialize(worker_index)
      @worker_index = worker_index
      LOGGER.info("Starting worker #{worker_index}")
      Thread.new do
        while true
          execute
        end
      end
    end

    private

    def execute
      starting_time = DateTime.now
      LOGGER.info("Worker #{@worker_index} is starting")
      sleep(5)
      stopping_time = DateTime.now
      # The difference between two DateTimes is a Rational
      # representing the number of days
      elapsed_time = ((stopping_time - starting_time) * MILLISECONDS_IN_A_DAY).to_f
      LOGGER.info("Worker #{@worker_index} is stopping, took #{elapsed_time}ms")
    end
  end

end