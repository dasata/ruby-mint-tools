class Account < ActiveRecord::Base
  has_many :transactions
  has_many :categories, through: :transactions 

  validates :name, presence: true,
                   length: { minimum: 3 }
  validates :account_type, presence: true

  enum account_type: [ :checking, :savings, :credit, :brokerage ]
end
