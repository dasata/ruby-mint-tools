class ReportsController < ApplicationController
  def month_summary
    @month = params[:month].to_i
    @year = params[:year].to_i
    @categories = Transaction.category_summary(@year, @month).order('categories.name')
  end
end
