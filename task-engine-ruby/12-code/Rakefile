desc 'Start the engine'

TASK_ENGINE_INSTANCE = 'TASK_ENGINE_INSTANCE'

task :start_engine do
  unless ENV.key?(TASK_ENGINE_INSTANCE)
    raise "Missing env variable #{TASK_ENGINE_INSTANCE}"
  end
  instance = ENV.fetch(TASK_ENGINE_INSTANCE)
  require_relative 'task_engine'
  require_relative 'tasks'
  TaskEngine::Engine.new(instance)
end

desc 'Create tasks'
task :create_tasks do
  require_relative 'task_engine'
  100.times do
    TaskEngine.create_task(
        'TaskEngine::Tasks::WaitingTask',
        {
            waiting_time: 5
        })
  end
end

task default: :start_engine