# encoding: utf-8

class PriceCreator
  attr_reader :prices

  def initialize(_params, delete_existing = false)
    Price.delete_all if delete_existing
    form     = ReadFileAndOrForm.new(_params)
    @data    = form.data
    create_models
  end

  def create_models
    @prices = []
    @data.each do |data|
      @model = ModelCreator.new(data.delete(:model), data).model
      build_relationships
      @prices << @model
    end
  end

  def build_relationships
    security = Security.find_by_name_or_ticker(@model.ticker)
    @model.security = security

    @model.name = security.name
    @model.save
  end

end
