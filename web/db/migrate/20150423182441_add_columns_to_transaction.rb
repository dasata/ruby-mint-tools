class AddColumnsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :original_description, :string
    add_column :transactions, :type, :string, limit: 1
  end
end
