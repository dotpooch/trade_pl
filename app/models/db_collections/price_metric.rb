# encoding: utf-8

class PriceMetric
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###
#  before_save :create_stub

  ### RELATIONSHIPS ###
  has_many    :prices,   class_name:'Price',    inverse_of: :price_metric, :dependent => :delete
  belongs_to  :security, class_name:'Security', inverse_of: :price_metric

  ### FIELDS ###
  field :names,         :type => Array
  field :symbols,       :type => Array
  field :cusip,         :type => Array
  field :security_type, :type => String
 
  field :start_date,    :type => Date
  field :end_date,      :type => Date
  field :count,         :type => Integer

  ### VALIDATIONS ###


  ### SCOPES ###


  ### INSTANCE METHODS ###
 
  def create_stub
    self.an = Global.format_string(security_name) if (alt_name.nil? || alt_name.empty?)
  end

  ### CLASS METHODS ###
  
  class << self
  
    def updated(_delete = false)
      PriceMetric.delete_all if _delete
      @security_names = Price.need_metric?
	  update
      alpha
    end

    def alpha
      metrics = []
      @security_names.map do |n|
        security = Security.where(:names => n).first
        metrics << security if security.names.last == n
      end
      metrics
    end

    def update_stubs
      PriceMetric.alpha.each do |metric|
        @metric = metric
        @metric.save
      end
    end

    def join_security(_security)
      prices = self.where(:n => _security).no_security
      _security.names.each do |name|
        name == _security.names.first ? prices = prices.and(:n => name) : prices = prices.any_of(:n => name)
      end
      prices.each { |price| price.update_security(_security) }
    end

  protected

    def update
      @security_names.each do |name|
        update_metric(name)
        update_prices(name)
      end
    end

    def update_prices(_name)
      Price.assign_metric(_name).each do |price|
        price.price_metric = @metric
        price.save
      end
    end

    def update_metric(_name)
      @metric = PriceMetric.find_or_initialize_by(:names => [_name])
      @metric.count       = Price.count_named(_name)
      @metric.start_date  = Price.oldest_date(_name)
      @metric.end_date    = Price.newest_date(_name)
      @metric.save
    end

  end
  
end
