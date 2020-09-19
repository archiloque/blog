Sequel.migration do
  change do
    alter_table(:tasks) do
      add_index [:status, :created_at]
    end
  end
end