# encoding: utf-8

class Ticker
  include Mongoid::Document
  include Mongoid::Timestamps

  ### RELATIONSHIPS ###
  has_and_belongs_to_many :securities, class_name: 'Security', inverse_of: :ticker_list
  
  ### FIELDS ###
  field :ticker,   :type => String,   :default => ""

end
