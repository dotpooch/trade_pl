# encoding: utf-8

class ExchangeTradedFund
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###
  before_save :create_stub

  ### RELATIONSHIPS ###
  has_many  :ids,                class_name:'ID',               inverse_of: :company#, autosave: true
  has_many  :prices,             class_name:'Price',           inverse_of: :company#, autosave: true

  ### FIELDS ###
  field :n,  :type => Array,  :as => :names
  field :an, :type => Array,  :as => :alt_names
  field :t,  :type => Array,  :as => :tickers
  field :d,  :type => String, :as => :description
  field :j,  :type => String, :as => :jottings
  
  ### VALIDATIONS ###
  validates_presence_of :names

  ### SCOPES ###
  scope :alpha,      all.asc(:an)
  scope :named,     ->(_name) {where(:n => _name)}
  scope :stubbed,   ->(_name) {where(:an => _name)}

  ### INSTANCE METHODS ###

  def name;       names.first;                         end
  def ticker;     tickers.first;                       end
  def alt_name;   alt_names.first;                     end
  def old_names;  names.size > 1 ? names.drop(1) : []  end

  def create_stub
    names.each do |name|
      self.an = []
      self.an << Global.format_string(name)
    end
  end

  ### CLASS METHODS ###
  
  class << self

    def update_stubs
      Company.alpha.each do |company|
        @company = company
        @company.save
      end
    end
  
  end

end
