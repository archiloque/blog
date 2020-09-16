Sequel.migration do
  change do
    alter_table(:tasks) do
      add_column :scheduled_at, DateTime, null: false, default: Sequel.lit('LOCALTIMESTAMP')
      drop_index [:status, :created_at]
      add_index [:status, :scheduled_at]
    end
  end
end