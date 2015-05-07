class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.page(params[:page]).per_page(100).order(date: :desc)
  end

  def show
    @transaction = get_selected_transaction
  end

  def new
    @transaction = Transaction.new
  end

  def edit
    @transaction = get_selected_transaction
  end

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.valid?
      @category = Category.find(@transaction.category_id)
      @transaction = @category.transactions.create(transaction_params)      
    end

    if @transaction.new_record?
      render 'new'
    else 
      redirect_to transaction_path(@transaction)
    end
  end

  def update
    @transaction = get_selected_transaction

    if @transaction.update(transaction_params)
      redirect_to transaction_path(@transaction)
    else 
      render 'edit'
    end
  end

  def destroy
    @transaction = get_selected_transaction
    @transaction.destory

    redirect_to transactions_path
  end

  private
    def transaction_params
      return params.require(:transaction).permit(:date, :description, :amount, :category_id)
    end

    def get_selected_transaction
      return Transaction.find(params[:id])
    end
end
