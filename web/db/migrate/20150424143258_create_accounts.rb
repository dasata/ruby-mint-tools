class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name

      t.timestamps null: false
    end

    change_table :transactions do |t|
      t.belongs_to :account, index:true
    end
  end
end
