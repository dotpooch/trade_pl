# encoding: utf-8

class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###
 # before_save :set_gross_principal, :set_fees, :set_net_principal

  ### RELATIONSHIPS ###
  belongs_to :security,    class_name:'Security',          inverse_of: :transactions
  belongs_to :trade,       class_name:'Trade',             inverse_of: :transactions
  belongs_to :entry,       class_name:'Entry',             inverse_of: :transactions
  belongs_to :exit,        class_name:'Exit',              inverse_of: :transactions
  has_many   :fills,       class_name:'Fill',              inverse_of: :transaction
  belongs_to :fill_date,   class_name:'FillDate',          inverse_of: :transaction
  belongs_to :fill_time,   class_name:'FillTime',          inverse_of: :transaction
  has_one    :returns,     class_name:'TransactionReturn', inverse_of: :transaction

  ### FIELDS ###
  field :live,  :type => String,   :default => true
  field :date,  :type => Date
  field :net_p, :type => Money,   :as => :net_price
  field :h,     :type => Money,   :as => :high
  field :l,     :type => Money,   :as => :low
  field :c,     :type => Money,   :as => :close
  field :ppor,  :type => Money,   :as => :price_percent_of_range
  field :pnpor, :type => Money,   :as => :price_net_percent_of_range
  field :piv,   :type => Money,   :as => :pivot
  field :piv2,  :type => Money,   :as => :pivot_2
  field :atr,   :type => Money,   :as => :avg_true_range
  field :atr_p, :type => Money,   :as => :avg_true_range_per
  field :o,     :type => String,  :as => :order_id
  field :sym,   :type => String,  :as => :symbol
  field :s,     :type => String,  :as => :stub
  field :q,     :type => Money,   :as => :quantity, :default => 0
  field :ft,    :type => String,  :as => :fill_type
  field :st,    :type => String,  :as => :security_type
  field :sn,    :type => String,  :as => :security_name
  field :ts,    :type => String,  :as => :trade_stub
  field :trans, :type => String,  :as => :transaction_stub
  field :cu,    :type => String,  :as => :cusip
  field :p,     :type => Money,   :as => :price
  field :gp,    :type => Money,   :as => :gross_principal, :default => 0
  field :c,     :type => Money,   :as => :commission,      :default => 0
  field :sf,    :type => Money,   :as => :sec_fee,         :default => 0
  field :f,     :type => Money,   :as => :fees,            :default => 0
  field :np,    :type => Money,   :as => :net_principal,   :default => 0
  field :j,     :type => String,  :as => :jottings

  ### SCOPES ###
  scope :of_type,     ->(_types)  { any_in(:ft =>  _types) }
  scope :for_symbol,  ->(_symbol) { where(:sym =>  _symbol) }
  scope :for_trade,   ->(_name)   { where(:ts =>   _name) }
  scope :for_date,    ->(_date)   { where(:date => _date) }
  scope :for_type,    ->(_type)   { where(:type => _type) }
  scope :for_order,   ->(_type)   { where(:o => _type) }
  scope :qry,         ->(_qry)    { where(_qry) }
  scope :arrange,      asc(:date).asc(:quantity).asc(:price).asc(:commission).asc(:sec_fee)

  ### METHODS ###

  ### CLASS METHODS ###

  class << self
  
    def long_entry;     ["Buy Long"];                                             end
    def long_exit;      ["Sell Long"];                                            end
    def short_entry;    ["Sell Short"];                                           end
    def short_exit;     ["Cover Short"];                                          end
    def corp_events;    ["Share Split","Share Dividend","Dividend Reinvestment"]; end
    def option_exp;     ["Option Expiration"];                                    end

    def buys;           long_entry.concat(short_entry).concat(corp_events);       end
    def sells;          long_exit.concat(short_exit).concat(option_exp);          end
    def long_entries;   long_entry.concat(corp_events);     end
    def long_exits;     long_exit.concat(option_exp);       end
    def short_entries;  short_entry.concat(corp_events);    end
    def short_exits;    short_exit.concat(option_exp);      end
    def longs;          long_entries.concat(long_exits);    end
    def shorts;         short_entries.concat(short_exits);  end

    def assemble
      transactions_to_make.each do |transaction|
        qry_hsh  = {:trans => transaction}
        fills    = Fill.qry(qry_hsh)
        aggregate_fills(fills)
      end
      Transaction.all.asc(:sym,:d)
    end

    def transactions_to_make
      (Fill.all.distinct(:trans) - Transaction.all.distinct(:stub)).sort
    end
  
    def aggregate_fills(_fills)
      @transaction = Transaction.new
      _fills.each do |fill|
        fill == _fills.first ? add_first_fill(fill) : add_subsequent_fills(fill)
        calculate_average_price
      end
      @transaction.save
    end

    def add_first_fill(_fill)
      @transaction.stub             = _fill.trans
      @transaction.date             = _fill.date
      @transaction.order_id         = _fill.order_id
      @transaction.symbol           = _fill.symbol
      @transaction.ft               = _fill.ft
      @transaction.security_type    = _fill.security_type
      @transaction.security_name    = _fill.security_name
      @transaction.trade_stub       = _fill.trade_stub
      @transaction.cusip            = _fill.cusip

      @transaction.quantity         = _fill.quantity
      @transaction.gross_principal  = _fill.gross_principal
      @transaction.commission       = _fill.commission
      @transaction.sec_fee          = _fill.sec_fee
      @transaction.fees             = _fill.fees
      @transaction.net_principal    = _fill.net_principal
    end

    def add_subsequent_fills(_fill)
      @transaction.quantity         += _fill.quantity
      @transaction.gross_principal  += _fill.gross_principal
      @transaction.commission       += _fill.commission
      @transaction.sec_fee          += _fill.sec_fee
      @transaction.fees             += _fill.fees
      @transaction.net_principal    += _fill.net_principal
    end

    def calculate_average_price
      @transaction.price     = @transaction.gross_principal / @transaction.quantity
      @transaction.net_price = @transaction.net_principal / @transaction.quantity
    end
  
  end

  ### INSTANCE METHODS ###

  def symbol=(_symbol);        self.sym = _symbol.downcase;       end

  def fill_type=(_type)
    long   = { 1 => "Buy Long", 6 => "Sell Long" }
    short  = { 2 => "Sell Short", 7 => "Cover Short" }
    corp   = { 3 => "Share Split", 4 => "Share Dividend", 5 => "Dividend Reinvestment" }
    option = { 8 => "Option Expiration" }
    order_type = long.merge(short).merge(corp).merge(option)
    self.ft = order_type[_type.to_i]
  end

end

#  DateTime.new(2001,2,3,4,5,6,'+7')
#  DateTime.new(year, month, day of month,hour,minute,seccond,region offset)
#  @date.strftime("%B #{@date.day.ordinalize}, %Y") # >>> Gives `June 18th, 2010`
