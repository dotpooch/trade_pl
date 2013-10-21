# encoding: utf-8

class ModelCreator
  attr_reader :model
  
  def initialize(model_class, _params)
    @model_class = model_class.constantize
    clean_data = remove_non_model_field_keys(_params)
    clean_data = convert_data_types(clean_data)
    @model = @model_class.find_or_create_by(clean_data)
  end

  def convert_data_types(_data)
#    _data[:quantity]    = _data[:quantity].to_i
    _data[:price]       = _data[:price].gsub!("$","").to_f if _data.has_key? :price
    _data[:commission]  = _data[:commission].gsub!("$","").to_f if _data.has_key? :commission
    _data[:sec_fee]     = _data[:sec_fee].gsub!("$","").to_f if _data.has_key? :sec_fee
    _data[:shares]      = _data[:shares].to_i if _data.has_key? :shares
    _data[:quantity]    = _data[:quantity].to_i if _data.has_key? :quantity
    _data[:contracts]   = _data[:contracts].to_i if _data.has_key? :contracts
    _data
  end

  def remove_non_model_field_keys(_data)
    _data.keep_if {|key,_| @model_class.fields.keys.include? key.to_s }
    #_data.keep_if {|key,_| @model_class.methods.sort.include? key.to_s }
  end

end

=begin
date|transaction_id|id_trade|sub_trade_ref|transaction_ref|ticker|time|quantity|price|commission|sec_fee|limit|limit_period|order|capital|net_price|year|quarter|month|month_of_quarter|week_of_year|week_of_quarter|week_of_month|week_with_holiday|day_of_year|day_of_month|day_of_week|day_before_holiday|day_after_holiday|hour_of_day|hour_of_day|hour_of_day|high|low|close|price_percent_of_range|price_percent_of_range|pivot|pivot2|average_true_range|average_true_range_percentage

{:date=>Fri, 10 Oct 2008, :ticker=>"aapl", :price=>"$95.00", :commission=>"$9.99", :sec_fee=>"$0.00", :notes=>"||transaction_id|5023|id_trade|887|sub_trade_ref|14|transaction_ref|1", :shares=>"100"}
=end
