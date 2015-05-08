class Transaction < ActiveRecord::Base
  belongs_to :category
  belongs_to :account
  validates :date, presence: true
  validates :amount, presence: true,
                     numericality: true
  validates :description, presence: true,
                          length: { minimum: 3 }
  validates :category, presence: true

  enum transaction_type: [ :debit, :credit ]

  def self.monthly_summary(start_date, end_date)
    return Transaction.select("date_part('month', date) as month, date_part('year', date) as year, transaction_type, sum(amount) as total")
      .joins(:category)
      .where("date >= :start_date and date < :end_date and exclude_from_reports = false", { start_date: start_date, end_date: end_date })
      .group("year, month, transaction_type")
      .order('year, month, transaction_type')
  end

  def self.category_summary(year, month)
    Transaction.select("categories.name, categories.id, sum(transactions.amount) as total")
      .joins(:category)
      .where("date_part('month', transactions.date) = :month AND " + 
               "date_part('year', transactions.date) = :year AND " + 
               "exclude_from_reports = false", 
               { month: month, year: year })
      .group('categories.name, categories.id')
  end

  def self.top_spending_categories(year, month, record_limit)
    return category_summary(year, month).order('total desc').limit(record_limit)
  end
end
