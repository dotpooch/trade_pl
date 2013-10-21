class ProfitabilityController < ApplicationController

  def index
    @profitability = Profitability.cycles
  end

  def show
    @profitability = Profitability.where(:nickname => (params[:id]))
    @returns       = Profitability.returns(@profitability) unless @profitability.empty?
    redirect_to(profitability_index_path) if @profitability.empty?
  end

end
