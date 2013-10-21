class Decimal
  include Mongoid::Fields::Serializable
  
  #converts the number to a BigDecimal for saving as an integer
  def serialize(object)
    if object
      object = ::BigDecimal.new(object.to_s) unless object.kind_of?(::BigDecimal)
      object = object.round(4) * 10000
      object.to_i  
    else
      d {"No Object sent to Money class for serializing"; object}
      BREAK
      object
    end
  end

  def deserialize(object)
    if object
      output = ::BigDecimal.new(object.to_s) / 10000
    else
      object
      #When the field is called but no value is set
    end
    #object ? (::BigDecimal.new(object.to_s) / 10000) : object
  end
  
  
end
