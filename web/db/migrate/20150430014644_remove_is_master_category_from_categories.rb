class RemoveIsMasterCategoryFromCategories < ActiveRecord::Migration
  def change
    change_table :categories do |t|
      t.remove :is_master_category
    end
  end
end
