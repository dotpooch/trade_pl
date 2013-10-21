# encoding: utf-8

class TickerCreator

  def initialize
    self
  end

  def find_or_create(_params)
    @ticker = _params[:ticker]
    format
    Ticker.find_or_create_by(ticker: @ticker)
  end

  protected
 
  def format
    #@ticker = @ticker.gsub(/[^0-9A-Za-z]/, '.').gsub('...', '.').gsub('..', '.').gsub('.', '_').downcase
    @ticker = @ticker.gsub(/[^0-9A-Za-z]/, '.').gsub('...', '.').gsub('..', '.').downcase
    @ticker = @ticker[0...-1] if @ticker.last(1) == "."
    @ticker = @ticker.gsub('.', '_')
  end

end
