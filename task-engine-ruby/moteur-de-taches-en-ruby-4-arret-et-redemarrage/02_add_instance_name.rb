Sequel.migration do
  change do
    alter_table(:tasks) do
      add_column :instance, String, null: true, text: true
    end
  end
end