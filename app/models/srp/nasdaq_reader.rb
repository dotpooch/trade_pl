# encoding: utf-8

class NasdaqReader
  attr_reader :name

  def initialize(_ticker)
    @ticker = _ticker
	@name = find_name_from_ticker
  end

  protected

  def find_name_from_ticker
    nasdaq_url
	line = read_webpage
	extract_name(line)
  end

  def nasdaq_url
    @url = "http://www.nasdaq.com/symbol/" + @ticker
  end
	  	  
  def read_webpage
    open(@url) do |web_page|
      web_page.each_line do |line|
	    return line if line.start_with? "<title>"
	  end
    end
  end

  def extract_name(_line)
    _line.split(" stock quote - ")[1].split(" stock price -")[0]
  end

end