class ChangeTypeColumnInTransactions < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.integer :transaction_type 

      Transaction.connection.execute("update transactions set transaction_type = 0 where type = 'd';")
      Transaction.connection.execute("update transactions set transaction_type = 1 where type = 'c';")

      t.remove :type
    end
  end

  def down
    change_table :transactions do |t|
      t.add_column :type, :string, limit: 1

      Transaction.connection.execute("update transactions set type = 'd' where transaction_type = 0;")
      Transaction.connection.execute("update transactions set type = 'c' where transaction_type = 1;")

      t.remove :transaction_type 
    end
  end
end
