# encoding: utf-8

class Trade
  include Mongoid::Document
  include Mongoid::Timestamps
  ### RELATIONSHIPS ###
  has_and_belongs_to_many :securities,   class_name:'Security',     inverse_of: :trades

  has_and_belongs_to_many :fill_dates,      class_name:'FillDate',      inverse_of: :trades
  has_and_belongs_to_many :start_fill_date, class_name:'FillDate',      inverse_of: :trade_starts
  has_and_belongs_to_many :end_fill_date,   class_name:'FillDate',      inverse_of: :trade_ends
  has_and_belongs_to_many :profitabilities, class_name:'Profitability', inverse_of: :trades
    
  has_many                :transactions, class_name:'Transaction',  inverse_of: :trade
  embeds_one              :entry,        class_name:'Entry',        inverse_of: :trade
  embeds_one              :exit,         class_name:'Exit',         inverse_of: :trade#, :store_as
  
  ### FIELDS ###
  field :stub,  :type => String
  field :type,  :type => String
  field :sym,    :type => String,   :as => :symbol
  field :sn,    :type => String,   :as => :security_name
  field :c,    :type => String,   :as => :cusip
  field :q,    :type => Money,   :as => :quantity
  field :st,    :type => String,   :as => :security_type
  field :desc,  :type => String,   :as => :description
  field :j,    :type => String,   :as => :jottings
  field :gpl,    :type => Money,    :as => :gross_profit_loss,        :default => 0
  field :npl,    :type => Money,    :as => :net_profit_loss,        :default => 0
  field :hp,    :type => Integer,  :as => :holding_period
  field :comp,  :type => String,   :as => :complexity
  field :i,     :type => Money,    :as => :capital_invested,      :default => 0
  field :r,     :type => Money,    :as => :return_on_investment
  field :comm,  :type => Money,    :as => :commission,           :default => 0
  field :other_fees,     :type => Money,   :default => 0
  field :start_date,     :type => Date
  field :end_date,       :type => Date
  field :ls,             :type => Boolean,   :as => :long

  def self.column_names
    self.fields.collect { |field| field[0] }
  end
  
  ### FIELD ALAISES ###
  def capital_used=(invest);   self.capital_invested = invest;                end
  def investment=(invest);     self.capital_invested = invest;                end
  def roi=(investment_return); self.return_on_investment = investment_return; end
  def profit_loss=(p_and_l);   self.profit_or_loss = p_and_l;                 end
  def profitloss=(p_and_l);    self.profit_or_loss = p_and_l;                 end
  def name=(s_name);           self.security_name = s_name;                   end

  def capital_used;            capital_invested;                              end
  def investment;              capital_invested;                              end
  def roi;                     return_on_investment;                          end
  def profit_loss;             profit_or_loss;                                end
  def profitloss;              profit_or_loss;                                end

  def long_or_short=(direction)
    direction == "short" ? self.long = false : self.long = true
  end
  def long_or_short;           long == true ? "long" : "short";               end

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
      trades = trades_needing_assembly
      trades.each do |trade|
        qry_hsh  = {:ts => trade}
        fills    = Fill.qry(qry_hsh).asc(:date,:ft)
        aggregate_fills(fills)
      end
      Trade.all
    end

    def trades_needing_assembly
      (Fill.all.distinct(:ts) - Trade.all.distinct(:stub)).sort
    end
  
    def aggregate_fills(_fills)
      @trade = Trade.new
      @long = long?(_fills)

      _fills.each do |fill|
        case fill
        when _fills.first; add_first_fill(fill)
        when _fills.last;  add_last_fill(fill)
        end
        append_fills(fill)
        invest_capital(fill)
      end
      @trade.save
    end

    def add_first_fill(_fill)
      @trade.stub              = _fill.trade_stub
      @trade.symbol            = _fill.symbol
      @trade.security_type     = _fill.security_type
      @trade.security_name     = _fill.security_name
      @trade.cusip             = _fill.cusip

      @trade.quantity          = 0
      @trade.gross_profit_loss = 0
      @trade.commission        = 0
      @trade.other_fees        = 0
      @trade.net_profit_loss   = 0
      @trade.start_date        = _fill.date
      @trade.long              = @long
    end

    def add_last_fill(_fill)
      @trade.end_date  = _fill.date
      @trade.hp        = @trade.end_date - @trade.start_date
    end

    def append_fills(_fill)
      @trade.quantity           += _fill.quantity if entry_transaction?(_fill)
      @trade.commission         += _fill.commission
      @trade.other_fees         += _fill.fees
      @trade.gross_profit_loss  += _fill.gross_principal
      @trade.net_profit_loss    += _fill.net_principal
    end

    def invest_capital(_fill)
      @trade.capital_invested  += _fill.net_principal.abs
      @trade.r = @trade.net_profit_loss.to_f / @trade.capital_invested.to_f
    end

    def long?(_fills)
      _fills.distinct(:ft).include? "Buy Long"
    end

    def long_entry?(_fill)
      entries = ["Buy Long"]#,"Share Split","Share Dividend","Dividend Reinvestment"]
      (@trade.ls == true  && entries.include?(_fill.ft))
    end

    def short_entry?(_fill)
      entries = ["Sell Short"]#,"Share Split","Share Dividend","Dividend Reinvestment"]
      (@trade.ls == false  && entries.include?(_fill.ft))
    end

    def entry_transaction?(_fill)
      entries = ["Buy Long","Sell Short","Share Split","Share Dividend","Dividend Reinvestment"]
      entries.include?(_fill.ft)
    end

  def self.column_names
    self.fields.collect { |field| field[0] }
  end

  ### FIELD ALAISES ###
  def capital_used=(invest);   self.capital_invested = invest;                end
  def investment=(invest);     self.capital_invested = invest;                end
  def roi=(investment_return); self.return_on_investment = investment_return; end
  def profit_loss=(p_and_l);   self.profit_or_loss = p_and_l;                 end
  def profitloss=(p_and_l);    self.profit_or_loss = p_and_l;                 end
  def name=(s_name);           self.security_name = s_name;                   end

  def capital_used;            capital_invested;                              end
  def investment;              capital_invested;                              end
  def roi;                     return_on_investment;                          end
  def profit_loss;             profit_or_loss;                                end
  def profitloss;              profit_or_loss;                                end
  #def name;                    stub.stub;                                end

  def long_or_short=(direction)
    direction == "short" ? self.long = false : self.long = true
  end
  def long_or_short;           long == true ? "long" : "short";               end

    def add_subsequent_fills(_fill)
      @trade.quantity           += _fill.quantity
      @trade.gross_profit_loss  += _fill.gross_principal
      @trade.commission         += _fill.commission
      @trade.other_fees         += _fill.fees
      @trade.net_profit_loss    += _fill.net_principal
    end

    def calculate_average_price
      @trade.price     = @trade.gross_principal / @trade.quantity
      @trade.net_price = @trade.net_principal / @trade.quantity
    end
  end

end

#  DateTime.new(2001,2,3,4,5,6,'+7')
#  DateTime.new(year, month, day of month,hour,minute,seccond,region offset)
#  @date.strftime("%B #{@date.day.ordinalize}, %Y") # >>> Gives `June 18th, 2010`
