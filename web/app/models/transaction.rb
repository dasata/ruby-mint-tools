class Transaction < ActiveRecord::Base
  belongs_to :category
  belongs_to :account
  validates :date, presence: true
  validates :amount, presence: true,
                     numericality: true
  validates :description, presence: true,
                          length: { minimum: 3 }
  validates :category, presence: true

  def transaction_type
    return (:type == 'd') ? 'debit' : 'credit'
  end
end
