class WelcomeController < ApplicationController
  def index
    current_month = Date.today
    current_month = current_month - (current_month.day - 1)
    summary = Transaction.monthly_summary(current_month << 3, current_month)
    @report = {}

    summary.each do |row|
      key = sprintf('%d-%d', row.month, row.year)
      @report[key] = { month: row.month, year: row.year } unless @report.has_key?(key)
      @report[key][row.debit? ? :debits : :credits] = row.total
    end

    @top_spending = Transaction.top_spending_categories(current_month.year, current_month.month, 10)
  end
end
