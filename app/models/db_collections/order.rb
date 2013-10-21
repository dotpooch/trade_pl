# encoding: utf-8

class Order
  include Mongoid::Document
  include Mongoid::Timestamps
 

  ### RELATIONSHIPS ###
  has_many   :fills,         class_name:'Fills',     inverse_of: :order

  ### FIELDS ###
  
end

#  DateTime.new(2001,2,3,4,5,6,'+7')
#  DateTime.new(year, month, day of month,hour,minute,seccond,region offset)
#  @date.strftime("%B #{@date.day.ordinalize}, %Y") # >>> Gives `June 18th, 2010`
