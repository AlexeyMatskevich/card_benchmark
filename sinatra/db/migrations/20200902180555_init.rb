Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :name, null: false
    end

    create_table(:debit_cards) do
      primary_key :id
      foreign_key(:user_id, :users)
      String :color, null: false
      Integer :count, null: false
      column :meta, :jsonb
    end

    create_table(:credit_cards) do
      primary_key :id
      foreign_key(:user_id, :users)
      String :color, null: false
    end
  end
end
