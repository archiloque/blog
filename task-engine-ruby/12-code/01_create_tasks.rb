Sequel.migration do
  change do
    # Load enum-related methods
    extension :pg_enum

    # Declare the enum with the list of allowed values
    create_enum(:task_status, ['waiting', 'running'])

    create_table(:tasks) do
      primary_key :id
      # The status column is using the task_status enum type
      task_status :status, null: false, default: 'waiting'

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end