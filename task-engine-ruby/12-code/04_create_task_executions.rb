Sequel.migration do
  change do
    add_enum_value(:task_status, 'stopped')

    create_table(:task_executions) do
      primary_key :id
      foreign_key :task_id, :tasks, null: false
      DateTime :started_at, null: false
      DateTime :stopped_at, null: true
      column :result, 'JSONB', null: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end