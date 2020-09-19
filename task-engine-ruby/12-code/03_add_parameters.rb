Sequel.migration do
  change do
    alter_table(:tasks) do
      add_column :task_class, String, null: false, text: true
      add_column :task_parameters, 'JSONB', null: false
    end
  end
end