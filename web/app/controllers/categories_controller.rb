class CategoriesController < ApplicationController
  def index
    @categories = Category.master_categories
  end

  def show
    @category = get_selected_category 
  end

  def new
    @category = Category.new
  end

  def edit
    @category = get_selected_category
  end

  def create
    @category = Category.new(category_params)
    
    if @category.save
      redirect_to @category
    else 
      render 'new'
    end
  end

  def update
    @category = get_selected_category

    if @category.update(category_params)
      redirect_to @category
    else
      render 'edit'
    end
  end

  def destroy
    @category = get_selected_category
    @category.destroy

    redirect_to categories_path
  end

  def monthly_transactions
    @category = get_selected_category 
    @transactions = @category.transactions_for_month(monthly_transactions_params[:month], monthly_transactions_params[:year])
  end

  private 
    def category_params
      return params.require(:category).permit(:name, :parent_id)
    end

    def monthly_transactions_params
      return params.permit(:month, :year)
    end

    def get_selected_category
      return Category.find(params[:id])
    end
end
