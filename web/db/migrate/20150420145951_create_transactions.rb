class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :description
      t.decimal :amount
      t.references :category, index: true

      t.timestamps null: false
    end
    add_foreign_key :transactions, :categories
  end
end
