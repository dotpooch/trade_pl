# encoding: utf-8

class Debt
  include Mongoid::Document
  include Mongoid::Timestamps

  ### RELATIONSHIPS ###
  belongs_to :corp,        class_name: 'Corporation',   inverse_of: :debts


  ### FIELDS ###

  ### VALIDATIONS ###

  ### SCOPES ###

  ### INSTANCE METHODS ###

  ### CLASS METHODS ###

end
