class AddTypeToAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.boolean :active, default: true, null: false
      t.integer :account_type, default: 1
    end
  end
end
