class TradesController < ApplicationController
  protect_from_forgery

  def index
    @trades = Trade.assemble
  end

  def show
    @trade    = Trade.where(:stub => params[:id]).first
    redirect_to(trades_path) if @trade.nil?    
  end


  def new
    @trade = Trade.new
  end

  def create
    TradeCreator.new
    t = Trade.new(params[:trade])
    if TradeCreator.new
      redirect_to trades_url
    end
  end

  private

  def sort_column
    Trade.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end

end
