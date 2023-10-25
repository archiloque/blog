require `'sinatra/base`'
require `'sequel`'
require `'logger`'

# Add hooks in sequel logging
# since it`'s called for each query
module Sequel
  class Database

    # Alias a method so we can override it
    # but still call the original
    alias :log_yield_old :log_yield

    # This method is called for each query
    # so we can use it to count
    def log_yield(sql, args=nil, &block)
      Thread.current[:queries_count] += 1
      log_yield_old(sql, args, &block)
    end

    # Alias a method so we can override it
    # but still call the original
    alias :log_duration_old :log_duration

    # This method is called to measure duration
    # so we can use it to measure duration
    def log_duration(duration, message)
      Thread.current[:queries_duration] += duration
      log_duration_old(duration, message)
    end

  end
end

class App < Sinatra::Base

  DB = Sequel.sqlite(
    `'`',
    :loggers => [Logger.new(STDOUT)]
  )

  # Hook called before each call
  before do
    # Initialize the thread local variables
    Thread.current[:queries_count] = 0
    Thread.current[:queries_duration] = 0
  end

  # Hook called after each call
  after do
    # Set the headers
    current_thread = Thread.current
    headers[`'X-QUERIES-COUNT`'] =
      current_thread[:queries_count].to_s
    headers[`'X-QUERIES-DURATION`'] =
      current_thread[:queries_duration].to_s
    # Clean the thread local variables
    current_thread[:queries_count] = nil
    current_thread[:queries_duration] = nil
  end

  # This is my service, you`'ll be impressed
  get `'/`' do
    # Simple query that doesn`'t need any table
    DB.run "SELECT `'OK`'"
    `'OK`'
  end

end
