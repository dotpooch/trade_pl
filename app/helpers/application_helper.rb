module ApplicationHelper

  @units = {:thousand => "k", :million => "m"}

  def words(_words)
    _words.map { |i| i.gsub("_"," ") }
  end

  def list_div(_content)
    list(content_tag(:div, _content))
  end

  def list(_content)
    content_tag(:li, _content)
  end

  ### NUMBER FORMATS ###
  def percent(_percentage, _mult, _deci);  number_to_percentage(_percentage*_mult, :precision => _deci);  end
  def money(_money, _deci);                number_to_currency(_money, :precision => _deci, :negative_format => "(%u%n)");               end

  def long_date(_date)
    _date.to_formatted_s(:long).split(" 00:00").first
  end

  def short_date(_date)
    #_date.to_formatted_s(:sohlong).split(" 00:00").first
    _date.strftime("%Y-%m-%d")
  end

end

=begin
number_to_currency(num, :precision => (num.round == num) ? 0 : 2)
num = 30.00  => $30
num = 30.05  => $30.05

:significant - If true, precision will be the # of significant_digits. If false, the # of fractional digits (defaults to true)
=end
