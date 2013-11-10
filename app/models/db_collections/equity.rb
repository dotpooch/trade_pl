# encoding: utf-8

class Equity < Security

  ### RELATIONSHIPS ###
  belongs_to :corporation,  class_name: 'Corporation',  inverse_of: :equities

  ### FIELDS ###
  field :issue_class,  :type => String
  field :adr,          :type => Boolean

  ### VALIDATIONS ###

  ### SCOPES ###

  ### INSTANCE METHODS ###

  ### CLASS METHODS ###

  
end
