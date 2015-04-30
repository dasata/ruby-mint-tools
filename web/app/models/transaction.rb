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
      .where("date >= :start_date and date < :end_date", { start_date: start_date, end_date: end_date })
      .group("year, month, transaction_type")
      .order('year, month, transaction_type')
  end
end
