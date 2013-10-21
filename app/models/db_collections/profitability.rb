# encoding: utf-8

class Profitability
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###

  
  ### VALIDATIONS ###


  ### RELATIONSHIPS ###
  has_and_belongs_to_many :orders,       class_name:'Order',       inverse_of: :profitabilities
  has_and_belongs_to_many :fills,        class_name:'Fill',        inverse_of: :profitabilities
  has_and_belongs_to_many :transactions, class_name:'Transaction', inverse_of: :profitabilities
  has_and_belongs_to_many :trades,       class_name:'Trade',       inverse_of: :profitabilities
  has_one                 :stub,         class_name:'Stub',        inverse_of: :profitability#, :store_as

  
  ### FIELDS ###
  field :nickname,      :type => String

  field :profit_loss,   :type => Money,  :default => 0
  field :gains,         :type => Money,  :default => 0
  field :losses,        :type => Money,  :default => 0

  field :avg_gain_loss, :type => Money,  :default => 0
  field :avg_gain,      :type => Money,  :default => 0
  field :avg_loss,      :type => Money,  :default => 0

  field :commissions,   :type => Money,  :default => 0
  field :other_fees,    :type => Money,  :default => 0
  field :total_fees,    :type => Money#, :default => {commissions + other_fees}

  field :gain_commissions,   :type => Money,  :default => 0
  field :gain_other_fees,    :type => Money,  :default => 0
  field :gain_total_fees,    :type => Money#, :default => {commissions + other_fees}

  field :loss_commissions,   :type => Money,  :default => 0
  field :loss_other_fees,    :type => Money,  :default => 0
  field :loss_total_fees,    :type => Money#, :default => {commissions + other_fees}

  field :total_invested,          :type => Money,  :default => 0
  field :invested_in_gains,       :type => Money,  :default => 0
  field :invested_in_losses,      :type => Money,  :default => 0

  field :avg_invested,            :type => Money,  :default => 0
  field :avg_invested_for_gains,  :type => Money,  :default => 0
  field :avg_invested_for_losses, :type => Money,  :default => 0

  field :gain_count,       :type => Integer, :default => 0
  field :loss_count,       :type => Integer, :default => 0
  field :total_count,      :type => Integer, :default => 0

  field :gain_percentage,  :type => Money#, :default => {gain_count.to_f / total_count.to_f}
  field :loss_percentage,  :type => Money#, :default => {loss_count.to_f / total_count.to_f}

  field :avg_return,       :type => Money#, :default => {gain_count.to_f / total_count.to_f}
  field :avg_gain_return,  :type => Money#, :default => {gain_count.to_f / total_count.to_f}
  field :avg_loss_return,  :type => Money#, :default => {loss_count.to_f / total_count.to_f}
  
  field :trades_opened,    :type => Integer
  field :trades_closed,    :type => Integer

  field :avg_holding_period,       :type => Money
  field :avg_gain_holding_period,  :type => Money
  field :avg_loss_holding_period,  :type => Money

  field :year,                  :type => Integer
  field :quarter,               :type => Integer
  field :month,                 :type => Integer
  field :week,                  :type => Integer
  field :day_of_year,           :type => Integer
  field :day_of_quarter,        :type => Integer
  field :day_of_month,          :type => Integer
  field :day_of_week,           :type => Integer
  field :week_of_month,         :type => Integer
  field :week_of_quarter,       :type => Integer
  field :month_of_quarter,      :type => Integer
  field :week_without_trading,  :type => Boolean
  field :day_before_no_trading, :type => Boolean
  field :day_after_no_trading,  :type => Boolean

  ### SCOPES ###
  scope :no_year,                  where(:year => nil)

  scope :no_year,                  where(:year => nil)
  scope :no_quarter,               where(:quarter => nil)
  scope :no_month,                 where(:month => nil)
  scope :no_week,                  where(:week => nil)
  scope :no_day_of_week,           where(:day_of_week => nil)
  scope :no_week_of_month,         where(:week_of_month => nil)
  scope :no_week_of_quarter,       where(:week_of_quarter => nil)
  scope :no_month_of_quarter,      where(:month_of_quarter => nil)
  scope :no_week_without_trading,  where(:week_without_trading => nil)
  scope :no_day_before_no_trading, where(:day_before_no_trading => nil)
  scope :day_after_no_trading,     where(:day_after_no_trading => nil)



  scope :no_major_periods,   no_year.no_quarter.no_month.no_week
  scope :no_subset_periods,  no_day_of_week.no_week_of_month.no_week_of_quarter.no_month_of_quarter
  scope :trading,            no_week_without_trading.no_day_before_no_trading.day_after_no_trading

  scope :just_year,          no_quarter.no_month.no_week.no_subset_periods.trading
  scope :just_month,         no_year.no_quarter.no_week.no_subset_periods.trading
  scope :just_quarter,       no_year.no_month.no_week.no_subset_periods.trading

  scope :lifetime,             ->{no_major_periods.no_subset_periods.trading}
  scope :annual,               ->{where(:year.ne => nil).just_year}
  scope :year,      ->(_year)  {where(:year => _year).just_year}
  scope :quarterly,            ->{where(:quarter.ne => nil).just_quarter}
  scope :quarter, ->(_quarter) {where(:quarter => _quarter).just_quarter}
  scope :monthly,              ->{where(:month.ne => nil).just_month}
  scope :month,     ->(_month)   {where(:month => _month).just_month}

  scope :day_of_week,              ->{where(:month.ne => nil).just_month}
  scope :weekday,   ->(_day)   {where(:day_of_week => _day).just_day}

  ### FIELD ALAISES ###

  ### INSTANCE METHODS ###

  public
  def accuracy;       loss_count == 0 ? "∞" : gain_count.to_f/loss_count.to_f; end
  def unit_accuracy;  invested_in_losses == 0 ? "∞" : invested_in_gains.to_f / invested_in_losses.to_f; end
  def accuracy_perc;        gain_count.to_f / total_count.to_f;   end
  def unit_accuracy_perc;   invested_in_gains.to_f / total_invested.to_f; end
  def impact;                avg_loss == 0 ? "∞"        : avg_gain.to_f/avg_loss.abs.to_f;                  end
  def unit_impact;    losses == 0 ? "∞"          : gains.to_f/losses.abs.to_f;                       end
  def return_impact;  loss_percentage == 0 ? "∞" : gain_percentage.to_f / loss_percentage.abs.to_f;  end
  def performance;    (accuracy == "∞" || impact == "∞" ) ? "∞" : accuracy.to_f * impact.to_f;       end

  def cycle
    c = ""
    c << "Year: #{year}, "                                   if year
    c << "Quarter: #{quarter}, "                             if quarter
    c << "Month: #{month}, "                                 if month
    c << "Week: #{week}, "                                   if week
    c << "Day of Year: #{day_of_year}, "                     if day_of_year
    c << "Day of Quarter: #{day_of_quarter}, "               if day_of_quarter
    c << "Day of Month: #{day_of_month}, "                   if day_of_month
    c << "Weekday: #{day_of_week}, "                         if day_of_week
    c << "Week of Month: #{week_of_month}, "                 if week_of_month
    c << "Week of Quarter: #{week_of_quarter}, "             if week_of_quarter
    c << "Month of Quarter: #{month_of_quarter}, "           if month_of_quarter
    c << "Week without Trading: #{week_without_trading}, "   if week_without_trading
    c << "Day before a Holiday: #{day_before_no_trading}, "  if day_before_no_trading
    c << "Day after a Holiday: #{day_after_no_trading}, "    if day_after_no_trading
    c.empty? ? c = "Lifetime" : c[0...-2]
  end

  
  private

  ### CLASS METHODS ###

  class << self

    public

      def returns(_profitabilities)      
        trades = _profitabilities.map { |i| i.trades  }
        qry = trades.flatten.inject([]) { |ary,trade| ary << {:trade_stub => trade.stub} }
        Investment_Returns.average_returns(qry)
      end

    
      def cycles
        Profitability.all
      end

      def make_calender_queries
        criteria = FillDate.map_queriable_fields
        fields = [
          [:y]#,
          #[:q],
          #[:m],[:moq],
          #[:woy],[:woq],[:wom],
          #[:doy],[:doq],[:dom],[:dow],
          #[:dbmc],[:damc],[:wwmc],
          #[:y,:q],[:y,:m],
          #[:q,:moq],[:q,:woq],[:q,:doq],
          #[:m,:wom],[:m,:dom]
          ]

        queries = fields.inject ([]){ |array,set| array << make_query(criteria, set) }
        queries.flatten!.unshift({})
      end
      
      def make_query(_criteria,_fields)
        hsh = Global.select_hash_keys(_criteria,_fields)
        Global.hash_product(hsh)
      end

      def query_trades
        queries = make_calender_queries
        queries.each do |query|
          trades = []
          dates  = query_dates(query)
          dates.each { |date| trades << date.trade_starts }
          trades.flatten!
          analyze_profitability(trades, query) if dates.count > 0
        end
      end

      def analyze_profitability(_trades,_qry)
        @invested       = {:total => 0, :gain => 0, :loss => 0, :even => 0}
        @holding_period = {:total => 0, :gain => 0, :loss => 0, :even => 0}

        @p = self.new
        @p.nickname = Stub.make
        @p.trades << _trades
        @p.total_count = _trades.count
        _trades.each do |trade|
           @trade = trade
           increment
        end
        average
        assign_query_period(_qry)
        @p.save
      end
    
    private
    
      def map_array(_i,_j);   (_i.._j).collect {|k| k};            end
      def query_dates(_qry);  FillDate.with_trades.where(_qry);    end

      def increment
        increment_total
        if     @trade.net_profit_loss > 0; increment_gain
        elsif  @trade.net_profit_loss < 0; increment_loss
        else   
        end
      end

      def average
        average_total
        average_("gains")
        average_("losses")
      end

      def assign_query_period(_qry)
        @p.year                   = _qry[:y]

        @p.quarter                = _qry[:q]

        @p.month                  = _qry[:m]
        @p.month_of_quarter       = _qry[:moq]

        @p.week                   = _qry[:woy]
        @p.week_of_quarter        = _qry[:woq]
        @p.week_of_month          = _qry[:wom]

        @p.day_of_year,           = _qry[:doy]
        @p.day_of_quarter,        = _qry[:doq]
        @p.day_of_month,          = _qry[:dom]
        @p.day_of_week            = _qry[:dow]

        @p.week_without_trading   = _qry[:wwmc]
        @p.day_before_no_trading  = _qry[:dbmc]
        @p.day_after_no_trading   = _qry[:damc]
      end

      def average_total
        count = @p.total_count
        
        @p.avg_gain_loss       = @p.profit_loss / count
        @p.avg_return          = @p.profit_loss / @p.total_invested
        @p.avg_invested        = @p.total_invested / count
        @p.avg_holding_period  = @holding_period[:total] / count
      end

      def average_(_type)
        plural   = _type
        singular = plural.singularize
 
        gain_or_loss        = @p.send(plural).to_f
        count               = @p.send("#{singular}_count").to_f
        capital_commitment  = @p.send("invested_in_#{plural}")
        holding_period      = @holding_period[singular.to_sym].to_f

        @p.send( "#{singular}_percentage=",         count / @p.total_count )         #win/loss percentage
        unless count == 0
          @p.send( "avg_#{singular}=",                gain_or_loss / count )              #average gain/loss
          @p.send( "avg_#{singular}_return=",         gain_or_loss / capital_commitment ) #average return
          @p.send( "avg_invested_for_#{plural}=",     capital_commitment / count )        #average capital commitment
          @p.send( "avg_#{singular}_holding_period=", holding_period / count )            #average holding period
        else
          @p.send( "avg_#{singular}=",                0 ) #average gain/loss
          @p.send( "avg_#{singular}_return=",         0 ) #average return
          @p.send( "avg_invested_for_#{plural}=",     0 ) #average capital commitment
          @p.send( "avg_#{singular}_holding_period=", 0 ) #average holding period
        end
      end

      def increment_total
        @p.commissions          += @trade.commission
        @p.other_fees           += @trade.other_fees
        @p.total_fees            = @p.commissions + @p.other_fees
        @p.profit_loss          += @trade.net_profit_loss
        @p.total_invested       += @trade.capital_invested
        @holding_period[:total] += @trade.holding_period.to_i
      end

      def increment_gain
        @p.gain_count           += 1
        @p.gain_commissions     += @trade.commission
        @p.gain_other_fees      += @trade.other_fees
        @p.gain_total_fees       = @p.gain_commissions + @p.gain_other_fees
        @p.gains                += @trade.net_profit_loss
        @p.invested_in_gains    += @trade.capital_invested
        @holding_period[:gain]  += @trade.holding_period.to_i
      end

      def increment_loss
        @p.loss_count            += 1
        @p.loss_commissions      += @trade.commission
        @p.loss_other_fees       += @trade.other_fees
        @p.loss_total_fees        = @p.loss_commissions + @p.loss_other_fees
        @p.losses                += @trade.net_profit_loss
        @p.invested_in_losses    += @trade.capital_invested
        @holding_period[:loss]   += @trade.holding_period.to_i
      end

  end
end
