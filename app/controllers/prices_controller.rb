class PricesController < ApplicationController

  def index
    @equities = Security.updated
  end

  def show
    @prices = Price.where(:symbols => params[:id])
    if @prices
      @prices
    else
      redirect_to prices_path
    end
  end

  def new
    @price = Price.new
  end

  def create
    @prices = PriceCreator.new(params)
    redirect_to prices_path
  end


end
