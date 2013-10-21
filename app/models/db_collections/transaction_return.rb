# encoding: utf-8

class TransactionReturn
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###

  ### RELATIONSHIPS ###
  belongs_to   :transaction,  class_name:'Transaction',  inverse_of: :returns

  ### FIELDS ###

  field :index,      :type => Integer
  field :date,       :type => Date
  field :open,       :type => Money
  field :high,       :type => Money
  field :low,        :type => Money
  field :close,      :type => Money

  field :stub,       :type => String
  field :symbol,     :type => String
  field :name,       :type => String
  field :fill_type,  :type => String

  ### FIELDS ###

  scope :stubbed, ->(_stub) {where(:stub => _stub)}

  ### INSTANCE METHODS ###

  public

  private

  ### CLASS METHODS ###

  class << self
  
    public

      def assemble(months_after = 12, months_before = 2)
        @months_after  = months_after
        @months_before = months_before
        transactions = Transaction.where(:roi => nil)
        transactions.each { |transaction| create_and_analyze(transaction) }
      end

      def re_assemble
        self.delete_all
        self.assemble
      end
    
    private
    
      def create_and_analyze(_transaction)
        initialize_variables(_transaction)
        analyze_roi
        join
      end

      def initialize_variables(_transaction)
        @transaction  = _transaction
        @roi          = self.new
      end

      def join
        @roi.transaction = @transaction
        @roi.save
      end
      
      def analyze_roi
        name_instance
        analyze_roi_after
        analyze_roi_before
      end

      def analyze_roi_before
        prices_before.each_index { |i| calculate_roi(-i, prices[i]) }
      end

      def analyze_roi_after
        prices_after.each_index { |i| calculate_roi(i, prices[i]) }
      end

      def prices_before
        Price.on_window_before(@roi.name, @transaction.date, @months_before).reverse
      end

      def prices_after
      Price
      gg =   Price.on_window_after(@roi.name, @roi.symbol, @transaction.date, @months_after)
      d {gg;gg.entries}
      BREAK
      end

      def calculate_roi(_index, _price)
        cost = @transaction.price
        @roi.index = _index
        @roi.open  = _price.open  / cost
        @roi.high  = _price.high  / cost 
        @roi.low   = _price.low   / cost 
        @roi.close = _price.close / cost
        B 
      end

      def name_instance
        @roi.stub           = Stub.make
        @roi.symbol         = @transaction.symbol
        @roi.name           = @transaction.security_name
        @roi.fill_type      = @transaction.fill_type
      end

  end

end

  
=begin


















    def additional_aliases
      more = {
      "day" => "d"
      }
      self.aliased_fields = aliased_fields.merge(more)
    end

    def calculate
      calculate_odds
      calculate_averages
      calculate_expectancies
    end

    def calculate_odds
      self.positive_odds  = positive_count / total_count
      self.negative_odds  = negative_count / total_count
      self.even_odds      = even_count / total_count
    end  

    def calculate_averages
      self.average_gain  = average(gains)
      self.average_loss  = average(losses)
    end  

    def calculate_expectancies
      self.gain_expectancy   = average_gain * positive_odds
      self.loss_expectancy   = average_loss * negative_odds
      self.total_expectancy  = gain_expectancy + loss_expectancy
    end

    def average(array)
      array.inject(0.0) {|sum, i| sum + i} / array.size
    end  




























    @investment_returns = []
    @window_size = 60
    @window_size.times {@investment_returns << {:returns => []}}

    LongEquityPurchaseTransaction.all.entries.each do |transaction|
      @transaction     = transaction
      date             = @transaction.fills.first.fill_date.date
      @buy_sell_price  = @transaction.fills.first.price
      @index           = @transaction.security.prices.where(date: date).entries.first.index
      returns_after_trade
    end


@investment_returns.size.times do

total, positive, negative, even, positive_odds, negative_odds, even_odds, avg_gain, avg_loss = 0, 0, 0, 0, 0, 0, 0, 0, 0

day = @investment_returns.shift
day[:returns].each do |transaction|
total += 1


end

 :avg_gain => avg_gain.round(4),
 :avg_loss => avg_loss.round(4),
 :total_exp => statistical_gain_loss(positive_odds, negative_odds, avg_gain, avg_loss)

measurements = {:measurements => odds}
odds_measurements = measurements.merge(odds)

end


  @total_count     << day[:total_count]
  @positive_count  << day[:positive_count]
  @negative_count  << day[:negative_count]
  @even_count      << day[:even_count]
  @positive_odds   << day[:positive_odds].round(2) * 100
  @negative_odds   << day[:negative_odds].round(2) * 100
  @even_odds       << day[:even_odds]
  @avg_gain        << day[:avg_gain].round(2) * 100
  @avg_loss        << (day[:avg_loss].round(2) * 100).abs
  @gain_exp        << (day[:positive_odds].round(2) * 100) * (day[:avg_gain].round(2) * 100)
  @loss_exp        << (day[:positive_odds].round(2) * 100) * (day[:avg_loss].round(2) * 100)
  @total_exp       << day[:total_exp].round(2) * 100
  @measurements    << day[:measurements]
end











  ### METHODS ###

  def set_fees
    self.fees = commission + sec_fee
  end  

  def set_name
    self.security_name = security.name unless security.nil?
  end

  field :security_type  :type => String, :default => "equity"
  field :position_type  :type => String, :default => "long"

  set_quantity_for_equities
    self.quantity = shares if security_type == "equity"
  end

  set_quantity_for_equities
    self.quantity = contracts * 100 if security_type == "option"
  end

  set_quantity_for_equities
    self.quantity = contracts * leverage_multiple if security_type == "commodity"
  end

  def set_net_principal
    self.net_principal = self.price * self.quantity
  end




end

#  DateTime.new(2001,2,3,4,5,6,'+7')
#  DateTime.new(year, month, day of month,hour,minute,seccond,region offset)
#  @date.strftime("%B #{@date.day.ordinalize}, %Y") # >>> Gives `June 18th, 2010`



  attr_reader   :total_count, :positive_count, :negative_count, :even_count
  attr_reader   :positive_odds, :negative_odds, :even_odds
  attr_reader   :avg_gain, :avg_loss, :measurements
  attr_reader   :gain_exp, :loss_exp, :total_exp

# The data sent here needs to be prepared the el only calculates the frequency not the 

  def initialize
    @investment_returns = []
    @window_size = 60
    @window_size.times {@investment_returns << {:returns => []}}

    LongEquityPurchaseTransaction.all.entries.each do |transaction|
      @transaction     = transaction
      date             = @transaction.fills.first.fill_date.date
      @buy_sell_price  = @transaction.fills.first.price
      @index           = @transaction.security.prices.where(date: date).entries.first.index
      returns_after_trade
    end


@investment_returns.size.times do

total, positive, negative, even, positive_odds, negative_odds, even_odds, avg_gain, avg_loss = 0, 0, 0, 0, 0, 0, 0, 0, 0

day = @investment_returns.shift
day[:returns].each do |transaction|
total += 1

case
when transaction[:close] >   0
  positive  += 1
  avg_gain  = (avg_gain * (total - 1) + transaction[:close].to_f).to_f / total.to_f
when transaction[:close] === 0; even      += 1
when transaction[:close] <   0
  negative  += 1
  avg_loss  = ( avg_loss * (total - 1) + transaction[:close].to_f ).to_f / total.to_f
end

positive_odds  = positive / total.to_f
negative_odds  = negative / total.to_f
even_odds      = even     / total.to_f
end

odds =  {:total_count => total,
 :positive_count => positive,
 :negative_count => negative,
 :even_count => even,
 :positive_odds => positive_odds.round(4),
 :negative_odds => negative_odds.round(4),
 :even_odds => even_odds.round(4),
 :avg_gain => avg_gain.round(4),
 :avg_loss => avg_loss.round(4),
 :total_exp => statistical_gain_loss(positive_odds, negative_odds, avg_gain, avg_loss)
}
measurements = {:measurements => odds}
odds_measurements = measurements.merge(odds)


@investment_returns << day.merge(odds_measurements)
end

some.instance_variable_get(("@thing_%d" % 2).to_sym)
some.instance_variable_set(:@thing_2, 55)
i = 1
s = Stuff.new
s.send("thing_#{i}=", :bar)
s.thing_1 

@total_count, @positive_count, @negative_count, @even_count  = Array.new(4) { [] }
@positive_odds, @negative_odds, @even_odds                   = Array.new(3) { [] }
@avg_gain, @avg_loss, @total_exp, @measurements              = Array.new(4) { [] }
@gain_exp, @loss_exp                                         = Array.new(2) { [] }

@investment_returns.each do |day|

  @total_count     << day[:total_count]
  @positive_count  << day[:positive_count]
  @negative_count  << day[:negative_count]
  @even_count      << day[:even_count]
  @positive_odds   << day[:positive_odds].round(2) * 100
  @negative_odds   << day[:negative_odds].round(2) * 100
  @even_odds       << day[:even_odds]
  @avg_gain        << day[:avg_gain].round(2) * 100
  @avg_loss        << (day[:avg_loss].round(2) * 100).abs
  @gain_exp        << (day[:positive_odds].round(2) * 100) * (day[:avg_gain].round(2) * 100)
  @loss_exp        << (day[:positive_odds].round(2) * 100) * (day[:avg_loss].round(2) * 100)
  @total_exp       << day[:total_exp].round(2) * 100
  @measurements    << day[:measurements]
end


  end

  def statistical_gain_loss(pos_odds, neg_odds, avg_gain, avg_loss)
    pos_exp = to_big_int(avg_gain) * to_big_int(pos_odds)
    neg_exp = to_big_int(avg_loss) * to_big_int(neg_odds)
    (pos_exp + neg_exp).div(10000.0).to_i/10000.0
  end

  def to_big_int(float)
    (float * 10000).to_i
  end

  def returns_after_trade
    i = 0
    prices = @transaction.security.prices.where(index: @index..(@index + @window_size - 1)).entries
    prices.each do |price|
      @price = price
      @investment_returns[i][:returns] << ohlc_returns
      i += 1
    end
  end

  def ohlc_returns
    ohlc_returns = {}
    ohlc_returns[:open]   = investment_return(@price.open, @buy_sell_price)
    ohlc_returns[:high]   = investment_return(@price.high, @buy_sell_price)
    ohlc_returns[:low]    = investment_return(@price.low, @buy_sell_price)
    ohlc_returns[:close]  = investment_return(@price.close, @buy_sell_price)
    ohlc_returns
  end

  def investment_return(a,b)
    ((a / b) -1).round(4)
  end

  def set_date_index
    i = 0
    @transaction.security.prices.all.order_by(:date, :asc).entries.each do |price|
      i += 1
      price.index = i
      price.save
    end
  end

  def create_price_index
    prices = w.security.prices.only(:index).order_by(:date, :asc)

    i = 0
    prices.each do |price|
      i += 1
      price.index = i
      price.save
    end
  end

  protected

  ### VALIDATIONS ###

  def validate_data(data)
    data if data_is_array?(data) && data_is_float_or_integer?(data)
  end

  def data_is_array?(data)
    error_message = ":data for the frequency must be contained in an array"
    raise(ArgumentError, error_message) unless data.is_a? Array
    true
  end

  def data_is_float_or_integer?(data)
    error_message = ":data for the frequency can only be integers or floats"
    data.each do |element|
      raise(ArgumentError, error_message) unless element.is_a?(Float) || element.is_a?(Integer)
    end
    true
  end

  def validate_interval(interval)
    raise(ArgumentError, ":interval frequency can only contain integers or floats") unless valid_interval? interval
    interval
  end

  def valid_interval?(interval)
    interval.is_a?(Float) || interval.is_a?(Integer)
  end

  ### METHODS ###
=end
