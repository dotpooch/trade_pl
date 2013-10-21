class TransactionsController < ApplicationController

#CorporationsController.instance_variable_get("@name")
#CorporationsController.instance_variable_set
#@model = key.capitalize
#@model.constantize

  def index
    Transaction.delete_all
    @transactions = Transaction.assemble
  end

  def show
    @transaction = Transaction.where(:s => (params[:id])).first
    @transaction ? render(:show) : redirect_to(transactions_path)
  end

  def new
    @transaction = Transaction.new
  end

  def create
    BREAK
  end

  def edit
    @transaction = Transaction.where(:transaction_stub => (params[:id])).first
    @transaction ? render(:edit) : redirect_to(transactions_path)
  end

  def update
    @transaction = Transaction.where(:stub => (params[:id])).first
    if @transaction.update(params[:issuer])
      flash[:success] = "Update: Successful"
      redirect_to @transaction
    else
      flash[:notice] = "Update: Error"
      render :edit
    end
  end

  def destroy
    @transaction = Transaction.where(:stub => (params[:id])).first
    @transaction.destroy
    redirect_to(transactions_path)
  end

end
