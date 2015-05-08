class AddExcludeFromReportsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :exclude_from_reports, :boolean, default: false
  end
end
