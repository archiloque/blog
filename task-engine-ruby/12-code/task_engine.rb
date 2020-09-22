require 'date'
require 'logger'
require 'sequel'

module TaskEngine

  LOGGER = Logger.new(STDOUT)
  NOTIFICATION_CHANNEL = 'task-engine'
  WORKERS_NUMBER = 5
  # Database connexion path
  DATABASE_URL = 'postgres://task_engine@localhost/task_engine'
  # Open the connexions to the database
  # Use at most
  # - one connexion per worker
  # - one connexion for notifications
  # - one connexion for the heartbeat
  DB = ::Sequel.connect(DATABASE_URL, max_connections: WORKERS_NUMBER + 2, logger: LOGGER)
  DB.extension :pg_json

  # The `created_at` and `updated_at` attributes should be managed by Sequel
  Sequel::Model.plugin :timestamps, force: true, update_on_create: true

  # Used to tag tasks classes that should not be retried
  module NoRetryTask
  end

  # Used to tag exception classes that should not trigger a retry when they happen
  module NoRetryException
  end

  class Task < Sequel::Model
    STATUS_WAITING = 'waiting'
    STATUS_RUNNING = 'running'
    STATUS_STOPPED = 'stopped'
    STATUS_FAILED = 'failed'
    one_to_many :task_executions
  end

  class TaskExecution < Sequel::Model
    STATUS_RUNNING = 'running'
    STATUS_SUCCESS = 'success'
    STATUS_FAILURE = 'failure'
    many_to_one :task
  end

  MILLISECONDS_IN_A_DAY = 24 * 60 * 60 * 1000

  # @param [String] task_class
  # @param [Hash] task_parameters
  # @param [DateTime, nil] scheduled_at nil means an immediate execution
  # @param [Hash] task_context
  def self.create_task(task_class, task_parameters, scheduled_at = nil)
    creation_params = {
        task_class: task_class,
        task_parameters: Sequel.pg_json_wrap(task_parameters)
    }
    # Don't send a null value to the DB so the DB use the default value
    unless scheduled_at.nil?
      creation_params[:scheduled_at] = scheduled_at
    end
    Task.create(creation_params)
    if scheduled_at.nil?
      DB.notify(NOTIFICATION_CHANNEL, payload: task_class)
    end
  end

  class Engine
    ENGINE_STATUS_RUNNING = 'running'
    ENGINE_STATUS_STOPPING = 'stopping'

    attr_reader :instance, :status, :queue

    def initialize(instance)
      unless Task.where(
          status: ENGINE_STATUS_RUNNING,
          instance: instance).empty?
        raise "Found running tasks with same instance name in the database [#{instance}]"
      end
      @instance = instance
      @queue = Queue.new
      @workers = []
      LOGGER.info('Starting engine')
      @status = ENGINE_STATUS_RUNNING

      Signal.trap('SIGTERM') do
        signal_trap
      end
      Signal.trap('SIGINT') do
        signal_trap
      end

      # Notifications
      Thread.new do
        DB.listen(NOTIFICATION_CHANNEL, loop: true) do |_channel, _pid, task_class|
          LOGGER.info("Received notification for a task [#{task_class}]")
          unless @queue.num_waiting == 0
            LOGGER.info('Notifying worker')
            @queue.push(task_class)
          end
        end
      end

      # Scheduled wake-ups
      Thread.new do
        while true do
          LOGGER.info('Scheduled wake-up')
          @queue.push('Scheduled wake-up')
          sleep(10)
        end
      end

      0.upto(WORKERS_NUMBER - 1) do |worker_index|
        @workers << Worker.new(self, worker_index)
      end
      @workers.each do |worker|
        LOGGER.info("Joining worker #{worker.worker_index}")
        worker.thread.join
      end
    end

    def signal_trap
      @status = ENGINE_STATUS_STOPPING
      @queue.close
    end
  end

  class Worker
    MAX_RETRIES_NUMBER = 10

    attr_reader :thread, :worker_index

    # @param [TaskEngine::Engine] engine
    # @param [Integer] worker_index
    def initialize(engine, worker_index)
      @engine = engine
      @worker_index = worker_index
      LOGGER.info("Starting worker #{worker_index}")
      @thread = Thread.new do
        execute
      end
    end

    private

    def execute
      while @engine.status == Engine::ENGINE_STATUS_RUNNING
        while (@engine.status == Engine::ENGINE_STATUS_RUNNING) && (task = try_acquire_task)
          starting_time = DateTime.now
          LOGGER.info("Worker #{@worker_index} starting task #{task.id}")

          task_execution = nil
          DB.transaction do
            task_execution = TaskExecution.create(
                task: task,
                started_at: starting_time,
                status: TaskExecution::STATUS_RUNNING
            )
          end

          task_class_name = task.task_class
          task_instance = nil
          begin
            task_class = Object.const_get(task_class_name)
            task_instance = task_class.new
            task_result = task_instance.execute(task.task_parameters)

            stopping_time = DateTime.now
            elapsed_time = (stopping_time - starting_time).to_f * MILLISECONDS_IN_A_DAY
            LOGGER.info("Worker #{@worker_index} finished successfully task #{task.id} in #{elapsed_time}ms, result is #{result}")
            DB.transaction do
              task_execution.update(
                  stopped_at: stopping_time,
                  result: Sequel.pg_json_wrap(task_result),
                  status: TaskExecution::STATUS_SUCCESS
              )
              task.update(
                  status: Task::STATUS_STOPPED
              )
            end
          rescue Exception => e
            stopping_time = DateTime.now
            elapsed_time = (stopping_time - starting_time).to_f * MILLISECONDS_IN_A_DAY
            LOGGER.info("Worker #{@worker_index} failed task #{task.id} in #{elapsed_time}ms, error is #{e.inspect}")
            DB.transaction do
              task_execution.update(
                  stopped_at: stopping_time,
                  error: Sequel.pg_json_wrap(
                      {
                          exception: e.class,
                          message: e.message,
                          backtrace: e.backtrace
                      }),
                  status: TaskExecution::STATUS_FAILURE
              )
            end
            if (!task_instance.nil?) && (task_instance.is_a?(TaskEngine::NoRetryTask))
              LOGGER.info("Worker #{@worker_index} task #{task.id} should not be retried")
              DB.transaction do
                task.update(
                    status: Task::STATUS_FAILED
                )
              end
            elsif e.is_a?(NoRetryException)
              LOGGER.info("Worker #{@worker_index} task #{task.id} raised a #{e.class} so it should not be retried")
              DB.transaction do
                task.update(
                    status: Task::STATUS_FAILED
                )
              end
            else
              current_retry_number = task.context['retry_number'] || 0
              if current_retry_number < MAX_RETRIES_NUMBER
                task.context['retry_number'] = current_retry_number + 1
                # 2^current_retry_number numbers of minutes / number of minutes in a day
                retry_scheduled_at = DateTime.now + Rational(2 ** current_retry_number, 1440)
                LOGGER.info("Worker #{@worker_index} task #{task.id} will be retried at #{retry_scheduled_at}")
                DB.transaction do
                  task.update(
                      status: Task::STATUS_WAITING,
                      context: task.context,
                      scheduled_at: retry_scheduled_at
                  )
                end
              else
                LOGGER.info("Worker #{@worker_index} task #{task.id} retries exhausted")
                DB.transaction do
                  task.update(
                      status: Task::STATUS_FAILED
                  )
                end
              end
            end
          end
        end
        # Wait until the notification awakes the worker
        LOGGER.info("Worker #{@worker_index} is sleeping")
        # We don't care about the message we got from the queue
        # since we just want to be awaken
        @engine.queue.pop
        LOGGER.info("Worker #{@worker_index} is awaken")
      end
      LOGGER.info("Worker #{@worker_index} is stopping")
    end

    # @return [TaskEngine::Task, nil]
    def try_acquire_task
      DB.transaction do
        task = Task.
            where(status: Task::STATUS_WAITING).
            where(Sequel.lit('scheduled_at < LOCALTIMESTAMP')).
            order(:scheduled_at).for_update.first
        unless task.nil?
          Task.where(id: task.id).update(
              status: Task::STATUS_RUNNING,
              instance: @engine.instance
          )
          task
        end
      end
    end
  end
end