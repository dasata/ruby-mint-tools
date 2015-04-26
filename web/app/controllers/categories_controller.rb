class CategoriesController < ApplicationController
  def index
    @categories = Category.all
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

  private 
    def category_params
      return params.require(:category).permit(:name)
    end

    def get_selected_category
      return Category.find(params[:id])
    end
end
