class AddIsMasterCategoryToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :is_master_category, :boolean, null:false, default:false
  end
end
