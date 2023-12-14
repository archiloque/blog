require 'sinatra/base'
require 'sequel'
require 'logger'
require 'sequel/database'

module Sequel

  # We'll monkey patch it since I didn't find a cleaner way to do it.
  class Database

    # Alias a method so we can override it
    # but still call the original
    alias :log_connection_yield_old :log_connection_yield

    # This method is called for each query
    # so we can use it to patch the query
    def log_connection_yield(sql, conn, args=nil, &block)
      # Can't patch the frozen Strings,
      # but as the frozen queries are used to create the connection
      # it's not a problem
      unless sql.frozen?
        # Prepend the current path
        sql.prepend("/* This query comes from [#{Thread.current[:current_sinatra_path]}] */ ")
      end
      # call the original
      log_connection_yield_old(sql, conn, args, &block)
    end

  end
end

class App < Sinatra::Base

  DATABASE = Sequel.sqlite(
    '',
    :loggers => [Logger.new(STDOUT)]
  )

  # Hook called before each call
  # Set the current path to be able to retrieve it
  before do
    # Initialize the thread local variable
    Thread.current[:current_sinatra_path] = request.fullpath
  end

  # This is my service, you'll be impressed
  get '/date' do
    # Simple query that doesn't need any table
    DATABASE.fetch('SELECT date(?) as d', 'now').first[:d]
  end

end
