Sequel.migration do
  change do
    extension :pg_enum

    create_enum(:task_status, ['waiting', 'running'])
    create_table(:tasks) do
      primary_key :id
      task_status :status, null: false, default: 'waiting'
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end