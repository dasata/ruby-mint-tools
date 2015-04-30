class Category < ActiveRecord::Base
  has_many :subcategories, class_name: 'Category',
                           foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Category'
  has_many :transactions
  has_many :accounts, through: :transactions
  validates :name, presence: true,
                   length: { minimum: 3 }

  def self.master_categories
    return Category.where(parent_id: nil).order(:name)
  end

  def monthly_amounts
    results = []
    self.transactions.select('date_part(\'year\', date) as year', 'date_part(\'month\', date) as month', 'sum(amount) as monthly_total')
      .group('year, month')
      .order('year desc, month desc')
      .each do |row|
        results.push({ 'year' => row['year'], 'month' => row['month'], 'total' => row['monthly_total'] })
    end

    return results
  end

  def transactions_for_month(month, year)
    return self.transactions
      .where("date_part('month', date) = :month AND date_part('year', date) = :year", 
            { month: month, year: year })
      .order(:date)
  end
end
