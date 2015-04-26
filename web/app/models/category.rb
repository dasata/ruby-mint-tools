class Category < ActiveRecord::Base
  has_many :subcategories, class_name: 'Category',
                           foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Category'
  has_many :transactions
  has_many :accounts, through: :transactions
  validates :name, presence: true,
                   length: { minimum: 3 }

  def monthly_amounts
    results = []
    self.transactions.select('date_part(\'year\', date) as year', 'date_part(\'month\', date) as month', 'sum(amount) as monthly_total').group('date_part(\'year\', date), date_part(\'month\', date)').each do |row|
      results.push({ 'year' => row['year'], 'month' => row['month'], 'total' => row['monthly_total'] })
    end

    results.sort_by! { |obj| Date.new(obj['year'], obj['month']) }   

    return results
  end
end
