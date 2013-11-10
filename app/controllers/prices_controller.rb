class PricesController < ApplicationController

  def index
    @equities = Security.updated
  end

  def show
	@prices = Price.where(:symbols => params[:id]).page(params[:page]).per(250)
    if @prices
      @prices
	  @closes = Price.closes(params[:id])
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
