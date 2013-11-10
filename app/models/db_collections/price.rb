# encoding: utf-8

class Price
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ### CALLBACKS ###
  before_validation :format_ticker
  before_save  :set_omc, :set_omr

  ### RELATIONSHIPS ###
  belongs_to :security,      class_name:'Security',    inverse_of: :prices
  belongs_to :price_metric,  class_name:'PriceMetric', inverse_of: :prices

  ### FIELDS ###
  field :names,         :type => Array
  field :symbols,       :type => Array
  field :cusips,        :type => Array
  field :security_type, :type => String
  field :issue_class,   :type => String
  field :adr,           :type => Boolean,  :default => false

  field :date_index,    :type => Integer
  field :date,          :type => Date
  field :open,          :type => Money
  field :high,          :type => Money
  field :low,           :type => Money
  field :close,         :type => Money
  field :volume,        :type => Integer
  field :adj_close,     :type => Money

  field :t,   :type => String,   :as => :ticker
  field :n,   :type => String,   :as => :company_name
  field :cu,  :type => String

  field :d,   :type => Date
  field :o,   :type => Money
  field :h,   :type => Money
  field :l,   :type => Money
  field :c,   :type => Money
  field :v,   :type => Integer
  field :ac,  :type => Money
  field :omc, :type => Money,    :as => :open_market_change
  field :omr, :type => Money,    :as => :open_market_return
  field :cmc, :type => Money,    :as => :closed_market_change
  field :cmr, :type => Money,    :as => :closed_market_return

  ### SCOPES ###
  #  self.prices.asc(:date).limit(100)
  scope :only_names,                only(:names).asc(:names)
  scope :no_metric,                where(:price_metric_id => nil)
  scope :no_security,              where(:security => nil)
  scope :all_sort_by_ticker_date,  all.order_by([:ticker, :asc],[:date, :asc])

  scope :day_gain,                ->(_gain) { where(:daytime_return.gte => _gain) } 
  scope :day_loss,                ->(_loss) { where(:daytime_return.lte => _loss) }
  scope :named,                   ->(_name) { where(:names => _name) }
  scope :with_ticker,             ->(_tckr) { where('ticker' => _tckr.downcase) }
  scope :unique,                  ->(_name, _ticker) {named(_name).with_ticker(_ticker)}

  scope :assign_metric,           ->(_name) { named(_name).no_metric.asc(:d) }
  scope :need_metric,             ->{ no_metric.only_names }
  scope :need_security,           ->{ no_security.only_names }

  scope :dated,         ->(_date)             { where(:d => _date) }
  scope :window_after,  ->(_date, _number_of) {where(:d.gte => _date)}#.and(:d.lte => (_date + _number_of.months)) }
  scope :window_before, ->(_date, _number_of) { where(:d.lte => _date).and(:d.gte => (_date - _number_of.months)) }
  
  scope :on,               ->(_name, _date) { named(_name).dated(_date) }
  scope :on_window_after,  ->(_name, _sym, _date, _window) { unique(_name,_sym)}#.window_after(_date,_window)  }
  scope :on_window_before, ->(_name, _sym, _date, _window) { unique(_name,_sym).window_before(_date,_window) }


  ### QUERIES ###
  
#  distinct(:n)
  
  class << self
    def count_named(_name);    named(_name).count                            end
    def need_metric?;          need_metric.distinct(:names)                  end
    def need_security?;        need_security.distinct(:names)                end
    def last_created(_name);   named(_name).distinct(:created_at).sort.last  end
    def ticker_by_date(_tckr); with_ticker(_tckr).asc(:d)                    end
    def unique_names;          all.distinct(:names)                          end
  end

  ### VALIDATIONS ###
  validates_presence_of :symbols, :names, :date, :open, :high, :low, :close

  ### INSTANCE METHODS ###

  public

    def set_omc;  self.open_market_change = close - open;                                 end
    def set_omr;  self.open_market_return = ((open_market_change / open) * 100).round 2;  end
  
    def calculate_daytime_returns
      self.each do |price|
        price.merge(:open_market_return => daytime_return)
      end
    end

    def security_attributes
      {:names => names, :symbols => symbols}
    end
  
    def update_security(_security)
      update_attributes(:security => _security)
    end

    def purge_security
      update_attributes(:security => nil, :names => nil, :symbols => nil)
    end
	
  protected
 
    def format_ticker; self.ticker =  self.ticker.downcase unless self.ticker.nil? end  #gsub(/^[0-9\.]/, ''))

  ### CLASS METHODS ###

  class << self

    public
    
	  def closes(_symbol)
	    closes = []
	    prices = where(:symbols => _symbol).order_by([:date, :desc]).limit(200).only(:close)
		prices.reverse.each do |price|
		  closes << price.close
		end
		closes
	  end
	
      def most_recent_date_by_symbol(_symbol) 
	    where(:symbols => _symbol).order_by([:date, :desc]).limit(1).first
	  end

      def most_recent
        all.distinct(:created_at).sort.last
      end

      def extreme_dates(_name)
        dates = named(_name).distinct(:date).sort
        [dates.first, dates.last]
      end

	  def closing_prices
        prices = self.prices.desc(:date).limit(100)
        prices = prices.sort! { |x, y| x[:date] <=> y[:date] }
        @recent_closes = []   
        prices.each {|price| @recent_closes << price.close}
        prices
      end


	  
      def aggregated_data(_name)
        price = where(:names => _name).first
        if price
          dates = extreme_dates(_name)
          {
          :count         => count_named(_name),
          :start_date    => dates.first,
          :end_date      => dates.last,
          :last_update   => last_created(_name),
          :names         => price.names,
          :symbols       => price.symbols,
          :cusips        => price.cusips,
          :adr           => price.adr,
          :issue_class   => price.issue_class
          }
        else
          {:last_update => most_recent}
        end        
      end

      def join_security(_security)
        prices = self.where(:names => _security.names.last, :security_id.ne => _security._id)
        prices.each { |price| price.update_security(_security) }
      end
      
      def purge_securities
        unique_names.each do |name|
          prices = named(name).each {|price| price.purge_security }
        end
      end

      def equities
        names = unique_names
        securities = []
        names.each do |name|
          hash = {}
          hash[:name]  = name
          hash[:count] = price_count(name)
          securities << hash
        end
        securities
      end

      def find_by_ticker(_ticker)
        prices = Price.ticker_by_date(_ticker)
      end

    private
  
  end

end
