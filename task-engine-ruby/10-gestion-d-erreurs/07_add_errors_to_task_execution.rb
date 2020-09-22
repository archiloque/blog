Sequel.migration do
  change do
    extension :pg_enum
    create_enum(:task_execution_status, ['running', 'success', 'failure'])
    alter_table(:task_executions) do
      add_column :status, :task_execution_status, null: false
      add_column :error, 'JSONB', null: true
    end
  end
end