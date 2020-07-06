require 'date'
require 'logger'
require 'sequel'

module TaskEngine

  LOGGER = Logger.new(STDOUT)
  WORKERS_NUMBER = 5
  DATABASE_URL = 'postgres://task_engine@localhost/task_engine'
  DB = ::Sequel.connect(DATABASE_URL, max_connections: WORKERS_NUMBER + 1, logger: LOGGER)

  MILLISECONDS_IN_A_DAY = 24 * 60 * 60 * 1000

  Sequel::Model.plugin :timestamps, force: true, update_on_create: true

  class Task < Sequel::Model
    STATUS_WAITING = 'waiting'
    STATUS_RUNNING = 'running'
  end

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
        execute
      end
    end

    private

    def execute
      starting_time = DateTime.now
      while (task = try_acquire_task)
        LOGGER.info("Worker #{@worker_index} starting task #{task.id}")
        sleep(0.1)
        stopping_time = DateTime.now
        elapsed_time = (stopping_time - starting_time).to_f * MILLISECONDS_IN_A_DAY
        LOGGER.info("Worker #{@worker_index} finished task #{task.id}, took #{elapsed_time}ms")
        end_task(task)
      end
      LOGGER.info("Worker #{@worker_index} is stopping")
    end

    # @return [TaskEngine::Task, nil]
    def try_acquire_task
      DB.transaction do
        task = Task.where(status: Task::STATUS_WAITING).order(:created_at).for_update.first
        unless task.nil?
          Task.where(id: task.id).update(status: Task::STATUS_RUNNING)
          task
        end
      end
    end

    # @param [TaskEngine::Task] task
    def end_task(task)
      DB.transaction do
        Task.where(id: task.id).delete
      end
    end
  end
end