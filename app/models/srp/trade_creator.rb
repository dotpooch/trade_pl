# encoding: utf-8

class TradeCreator

  def initialize
    Trade.delete_all
    Security.only(:tickers, :id).each do |security|
      @security = security
      create_trades_from_transactions unless @security.transactions.empty?
    end
  end

  def create_trades_from_transactions
    [long_transaction_types, short_transaction_types].each do |transactions|
      @transactions =  @security.transactions.any_in(_type: transactions).order_by([:datetime, :asc]).entries
      create_trades
    end
  end

  def create_trades
    create_new_trade
    until @transactions.empty? do
      @transaction = @transactions.shift
      first_entry_date?
      long_or_short?
      adjust_fees
      adjust_capital_invested
      adjust_profit_loss
      adjust_quantity
      join_transaction_and_trade
      save_trade if @quantity == 0
    end
  end

  def save_trade
    last_exit_date
    calculate_roi
    calculate_holding_period
    @trade.save

    create_new_trade unless @transactions.empty?
  end

  def create_new_trade
    @quantity = 0
    @trade = Trade.new
    @trade.name = random_name

    @trade.entry = Entry.new
    @trade.exit   = Exit.new
    @security.trades << @trade
  end
  
  def delete_unconnected_stubs
#(:url.ne => "", :url.exists => true)
    Stub.where(security_id: nil, trade_id: nil).delete
  end  

  def create_stub_and_join(trade_name)
    stub = Stub.create(stub: trade_name)

    stub.trade = @trade
    @trade.stub = stub
    stub.save
  end  

  def random_name
    #RandomWord.nouns.next
    #RandomWord.adjs.next
    #trade_name = Webster.new.random_word

    delete_unconnected_stubs
    new_stub = false
    until new_stub
      #trade_name = Webster.new.random_word
      trade_name = RandomWordGenerator.word
      unless Stub.where(stub: trade_name).exists?
        create_stub_and_join(trade_name)
        new_stub = true
      end
    end
  end

  def join_transaction_and_trade
    @transaction.trade = @trade
    if @trade.long_or_short == "long" 
      @transaction._type.include?("Purchase") ? join_entry : join_exit
    else
      @transaction._type.include?("Sale") ? join_entry : join_exit
    end
  end
 
  def join_entry
    @trade.entry.transactions << @transaction
  end

  def join_exit
    @trade.exit.transactions << @transaction
  end

  def calculate_roi
    @trade.roi = (@trade.profit_or_loss / @trade.investment) * 100
  end

  def adjust_fees
    adjust_commissions
    adjust_other_fees
  end

  def adjust_other_fees
    @trade.other_fees  = @trade.other_fees + @transaction.sec_fee
  end

  def adjust_commissions
    @trade.commissions  = @trade.commissions + @transaction.commission
  end

  def long_or_short?
    (@transaction._type.include?("Long") ? @trade.long_or_short=("long") : @trade.long_or_short=("short")) if @trade.capital_invested == 0
  end

  def adjust_capital_invested
    adjust_capital_invested_for_longs if @trade.long_or_short == "long"
    adjust_capital_invested_for_shorts if @trade.long_or_short == "short"
  end

  def adjust_capital_invested_for_longs
    @trade.investment += @transaction.net_principal unless @transaction._type.include?("Purchase")
  end

  def adjust_capital_invested_for_shorts
    @trade.investment -= @transaction.net_principal if @transaction._type.include?("Sale")
  end

  def adjust_quantity
    @transaction._type.include?("Sale") ? @quantity -= @transaction.shares : @quantity += @transaction.shares
  end

  def adjust_profit_loss
    @transaction._type.include?("Sale") ? @trade.profit_or_loss += @transaction.net_principal : @trade.profitloss -= @transaction.net_principal
  end

  def calculate_holding_period
    @trade.holding_period  = (last_exit_date - @trade.start_date).to_i
  end

  def first_entry_date?
    @trade.start_date  = @transaction.datetime if @trade.capital_invested == 0
  end


  def last_exit_date
    @trade.end_date  = @transaction.datetime
  end

  def transaction_types
    all_transaction_types
    long_transaction_types
    short_transaction_types
  end

  def all_transaction_types
    @all_transaction_types = @security.transactions.only(:type).entries.inject([]){|array,t|  array << t[:_type]}.uniq
  end

  def long_transaction_types
    all_transaction_types if @all_transaction_types == nil 
    selected_transaction_types("Long")
  end

  def short_transaction_types
    all_transaction_types if @all_transaction_types == nil 
    selected_transaction_types("Short")
  end

  def selected_transaction_types(long_short)
    @all_transaction_types.inject([]){|array,t| t.include?(long_short) ? array << t : array }
  end

end
