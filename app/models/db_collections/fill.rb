# encoding: utf-8

class Fill
  include Mongoid::Document
  include Mongoid::Timestamps
 
  before_save   :set_fees, :set_gross_principal, :set_net_principal, :set_name

  ### RELATIONSHIPS ###
  belongs_to :security,     class_name:'Security',     inverse_of: :fills#, autosave: true
  belongs_to :trade,        class_name:'Trade',        inverse_of: :fills#, autosave: true
  belongs_to :transaction,  class_name:'Transaction',  inverse_of: :fills
  belongs_to :order,        class_name:'Order',        inverse_of: :fills
  belongs_to :account,      class_name:'Account',      inverse_of: :fills
  belongs_to :fill_date,    class_name:'FillDate',     inverse_of: :fills
  belongs_to :fill_time,    class_name:'FillTime',     inverse_of: :fills

  ### FIELDS ###
  field :date,  :type => DateTime, :as => :date
  field :o,     :type => String,   :as => :order_id
  field :sym,   :type => String,   :as => :symbol
  field :s,     :type => String,   :as => :stub
  field :q,     :type => Money,    :as => :quantity#, :as => :shares
  field :ft,    :type => String,   :as => :fill_type
  field :st,    :type => String,   :as => :security_type
  field :sn,    :type => String,   :as => :security_name
  field :ts,    :type => String,   :as => :trade_stub
  field :trans, :type => String,   :as => :transaction_stub
  field :cu,    :type => String,   :as => :cusip
  field :p,     :type => Money,    :as => :price
  field :gp,    :type => Money,    :as => :gross_principal
  field :c,     :type => Money,    :as => :commission,      :default => 0
  field :sf,    :type => Money,    :as => :sec_fee,         :default => 0
  field :f,     :type => Money,    :as => :fees,            :default => nil
  field :np,    :type => Money,    :as => :net_principal
  field :j,     :type => String,   :as => :jottings

  ### SCOPES ###
  scope :of_type,     ->(_types)  { any_in(:ft =>  _types) }
  scope :for_symbol,  ->(_symbol) { where(:sym =>  _symbol) }
  scope :for_trade,   ->(_name)   { where(:ts =>   _name) }
  scope :for_date,    ->(_date)   { where(:date => _date) }
  scope :for_type,    ->(_type)   { where(:type => _type) }
  scope :for_order,   ->(_type)   { where(:o => _type) }
  scope :qry,         ->(_qry)    { where(_qry) }
  scope :arrange,      asc(:date).asc(:quantity).asc(:price).asc(:commission).asc(:sec_fee)

  scope :estimate_transactions,   ->(_name,_date, _type) {for_trade(name).for_date(date).for_type(_type).arrange}

=begin
Rules for Aggregating Fills
   I. fills with the same subtrade and transaction # are from the same order
 -- if no LEGACY subtrade order
    B. fills from the same day are from the same order
 -- if no time of day
    A. ask

 guidline a. fills on different days are from different orders
 guidline b. fills from vastly different times of day are from different orders
=end

  ### METHODS ###

  ### CLASS METHODS ###

  class << self
  
    def long_entry;     ["Buy Long"];                                             end
    def long_exit;      ["Sell Long"];                                            end
    def short_entry;    ["Sell Short"];                                           end
    def short_exit;     ["Cover Short"];                                          end
    def corp_events;    ["Share Split","Share Dividend","Dividend Reinvestment"]; end
    def option_exp;     ["Option Expiration"];                                    end

    def buys;           long_entry.concat(short_exit).concat(corp_events);        end
    def sells;          long_exit.concat(short_entry).concat(option_exp);         end
    def long_entries;   long_entry.concat(corp_events);     end
    def long_exits;     long_exit.concat(option_exp);       end
    def short_entries;  short_entry.concat(corp_events);    end
    def short_exits;    short_exit.concat(option_exp);      end
    def longs;          long_entries.concat(long_exits);    end
    def shorts;         short_entries.concat(short_exits);  end

    def name_fills_trades_transactions
      symbols = Fill.all.distinct(:sym)
      symbols.each {|sym| rename(sym)}
    end

    def rename(_symbol)
      qry_hsh = {:sym => _symbol}
      name_fills(qry_hsh)#                            if fills_need_naming?(qry_hsh)
      rename_trades(qry_hsh)                         if trades_need_naming?(qry_hsh)
      name_transactions_by_order_id(qry_hsh)         if transactions_need_naming?(qry_hsh)
      name_transactions_by_exisitng_trades(qry_hsh)  if transactions_need_naming?(qry_hsh)
     #name_transactions_by_estimated_trades(qry_hsh) if transactions_need_naming?(qry_hsh)
     # qry_hsh = {:sym => _symbol}
     # Fill.qry(qry_hsh)
    end

    def fills_need_naming?(_qry_hsh)
      _qry_hsh[:s] = nil
      fills = Fill.qry(_qry_hsh)
    end

    def name_fills(_qry_hsh)
      _qry_hsh[:s] = nil
      fills = Fill.qry(_qry_hsh)
      fills.each do |fill|
        fill.s = Stub.make
        fill.save
      end
    end

    def trades_need_naming?(_qry_hsh)
      sym = "#{_qry_hsh[:sym].upcase}_"
      _qry_hsh.delete(:s)
      _qry_hsh[:ts] = /#{sym}/
      Fill.qry(_qry_hsh).count > 0
    end
    
    def rename_trades(_qry_hsh)
      trades = Fill.qry(_qry_hsh).distinct(:ts)
      trades.each do |trade|
        _qry_hsh[:ts] = trade
        fills = Fill.qry(_qry_hsh)
        rename_trades_fills(fills)         
      end
    end

    def make_stub
      self.stub  = Stub.make
      self.save
    end

    def rename_trades_fills(_fills)
      stub  = Stub.make
      _fills.each {|fill| rename_trade(fill, stub)}
    end
  
    def rename_trade(_fill, _stub)
      sym = "#{_fill.symbol.upcase}_"
      if "" == _fill.trade_stub.split(sym).first
        _fill.trade_stub = _stub
        _fill.save
      end
    end

    def rename_trade?(_qry_hsh)
      _qry_hsh[:ts] = /#{_qry_hsh[:sym]}_/
      fills = Fill.qry(_qry_hsh).count > 0
    end

    def name_transactions_by_order_id(_qry_hsh)
      orders = Fill.qry(_qry_hsh).distinct(:o)
      orders.each do |order|
        _qry_hsh[:o] = order
        fills = Fill.qry(_qry_hsh)
        rename_transaction_fills(fills)
      end
    end

    def name_transactions_by_exisitng_trades(_qry_hsh)
      trades = Fill.qry(_qry_hsh).distinct(:ts)
      trades.each do |trade|
        _qry_hsh.delete(:date)
        _qry_hsh.delete(:ft)
        _qry_hsh[:ts] = trade
        types = Fill.qry(_qry_hsh).distinct(:ft)
        types.each do |type|
          _qry_hsh.delete(:date)
          _qry_hsh[:ft] = type
          dates = Fill.qry(_qry_hsh).distinct(:date)
          dates.each do |date|
            _qry_hsh[:date] = date
            fills = Fill.qry(_qry_hsh)
            rename_transaction_fills(fills)         
          end
        end
      end
    end

    def transactions_need_naming?(_qry_hsh)
      _qry_hsh.delete(:ts)
      orders = Fill.qry(_qry_hsh).distinct(:o)
      orders.each do |order|
        _qry_hsh[:o] = order
        fills = Fill.qry(_qry_hsh)
        rename_transaction_fills(_fills)
      end
    end
  
    def rename_transaction_fills(_fills)
      stub  = Stub.make
      _fills.each {|fill| rename_transaction(fill, stub)}
    end
  
    def rename_transaction(_fill, _stub)
      if _fill.transaction_stub.nil?
        _fill.transaction_stub = _stub
        _fill.save
      end
    end

  end

  ### INSTANCE METHODS ###
  def symbol=(_symbol);     self.sym = _symbol.downcase;                         end

  def fill_type=(_type)
    long   = { 1 => "Buy Long", 6 => "Sell Long" }
    short  = { 2 => "Sell Short", 7 => "Cover Short" }
    corp   = { 3 => "Share Split", 4 => "Share Dividend", 5 => "Dividend Reinvestment" }
    option = { 8 => "Option Expiration" }
    order_type = long.merge(short).merge(corp).merge(option)
    self.ft = order_type[_type.to_i]
    self.ft = _type if ( ft.nil? && order_type.values.include?(_type) )
  end

  def set_gross_principal
    unless ( quantity.nil? || price.nil? )
      self.gross_principal = quantity * price
      self.gross_principal = -self.gross_principal if Fill.buys.include?(ft)
    end
  end

  def set_net_principal
    self.net_principal = gross_principal + fees unless ( gross_principal.nil? || fees.nil? )
  end

  def set_fees
    self.fees = commission + sec_fee if fees.nil?
  end  

  def set_name
    self.security_name = Stub.make unless security_name?
  end  
end
