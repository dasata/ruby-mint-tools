class AddParentToCategories < ActiveRecord::Migration
  def change
    change_table :categories do |t|
      t.references :parent, index: true
    end
  end
end
