# Cycle on a list until everything is deleted
# Yield to generate the SQL code to drop it
def iterate_cycle(connection, type, elements)
  STDOUT << "#{elements.length} #{type}(s) found\n"
  until elements.empty?
    STDOUT << "Cycling in #{elements.length} #{type}(s) left\n"
    not_deleted_elements = []
    elements.each do |element|
      begin
        connection.exec(yield(element)) do |result|
        end
        STDOUT << " #{type} #{element[:name]} dropped\n"
      rescue PG::DependentObjectsStillExist
        STDOUT << " #{type} #{element[:name]} has a dependency and can't be dropped\n"
        not_deleted_elements << element
      end
    end
    if elements.length == not_deleted_elements.length
      raise "Blocked: #{elements.length} #{type}(s) are left: #{elements.join(',')}"
    end
    elements = not_deleted_elements
  end
  STDOUT << "All #{type}s dropped\n\n"
end

# Drop all triggers
def drop_triggers(connection)
  triggers = []
  connection.exec(
    'SELECT tgname, relname
    FROM pg_trigger, pg_class
    WHERE tgrelid=pg_class.oid and tgisinternal = false'
  ) do |result|
    result.each_row do |row|
      triggers << {:name => row[0], :table => row[1]}
    end
  end
  iterate_cycle(connection, 'trigger', triggers) do |trigger|
    "drop trigger #{trigger[:name]} on #{trigger[:table]}"
  end
end

# Drop all functions
def drop_functions(connection)
  functions = []
  connection.exec_params(
    'select proname, p.oid, pg_get_function_identity_arguments(p.oid)
    from pg_proc p
    join pg_namespace ns on ns.oid = p.pronamespace
    where ns.nspname = $1',
    ['public']
  ) do |result|
    result.each_row do |row|
      functions << {:name => row[0], :oid => row[1], :args => row[2]}
    end
  end
  iterate_cycle(connection, 'function', functions) do |function|
    "drop function #{function[:name]}(#{function[:args]})"
  end
end

# Drop all tables
def drop_tables(connection)
  tables = []
  connection.exec_params(
    'select tablename from pg_catalog.pg_tables where schemaname = $1',
    ['public']
  ) do |result|
    result.each_row do |row|
      tables << {:name => row[0]}
    end
  end
  iterate_cycle(connection, 'table', tables) do |table|
    "drop table #{table[:name]}"
  end
end

# Clear everything from the database
def clear_database(host, port, user, password, database)
  require 'pg'
  connection = PG::Connection.new(
    {
      :host => host,
      :port => port,
      :user => user,
      :password => password,
      :dbname => database,
    })
  drop_triggers(connection)
  drop_functions(connection)
  drop_tables(connection)
end
