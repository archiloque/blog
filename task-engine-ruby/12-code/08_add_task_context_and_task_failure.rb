Sequel.migration do
  change do
    extension :pg_enum
    add_enum_value(:task_status, 'failed')

    extension :pg_json
    alter_table(:tasks) do
      add_column :context, 'JSONB', null: false, default: Sequel.pg_json_wrap({})
    end
  end
end