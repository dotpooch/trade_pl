# encoding: utf-8

class PreferredEquity
  include Mongoid::Document
  include Mongoid::Timestamps

  ### RELATIONSHIPS ###
  belongs_to :corporation,  class_name: 'Corporation',   inverse_of: :preferred_equities

  ### FIELDS ###

  ### VALIDATIONS ###

  ### SCOPES ###

  ### INSTANCE METHODS ###

  ### CLASS METHODS ###

end
