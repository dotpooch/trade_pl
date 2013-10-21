# encoding: utf-8

class ReadFileAndOrForm
  attr_reader :data#, :models

=begin
Maybe it's good to use this or something like it

@people = []
p.valid? ? @people << p : @errors["#{@counter+1}"] = p.errors
=end

  def initialize(_params)
    @data = []
    @params = get_models(_params)
    read_models
  end

  def read_models
    @params.each_pair do |key,value|
      @model = key.capitalize
      read_folder_or_file(value.delete(:file)) if value[:file]
      read_form
    end
  end

  def form_models(_params)
    unneeded_keys = ["utf8", "authenticity_token", "commit", "action", "controller"]
    @models = _params.keys - unneeded_keys
  end

  def get_models(_params)
    form_models(_params).inject({}){|hash, key| hash[key] = _params[key]; hash}
  end

  def read_folder_or_file(_path)
    read_file(_path)
    #@params[@model.downcase]["folder"].include?("true") ? read_folder(_path) : read_file(_path)
  end

  def read_folder(_path)
    files = Dir[_path +"*"] if _path.last(1) 
    files.each do |file|
      ReadFile.new(file).data unless file[-1] == "~"
    end
  end

  def read_file(_path)
    FileReader.new(@model, _path).output.each{|i| @data << i}
  end

  def read_form
    unless params_empty?
      @params_model[:model] = @model
      @data << @params_model 
    end
  end

  def prepare_params_model
    @params_model  = @params[@model.downcase].inject({}){|hash, (k,v)| hash[k.to_sym] = v; hash}
    default_model   = @model.constantize.new
    @params_model.each {|k,v| @params_model.delete(k) if (v.blank? || v.nil? || default_model[k].to_s == @params_model[k])}
  end

  def params_empty?
    prepare_params_model
    @params_model.empty? ? true : @params_model[:model] = @model ; @params_model
  end

end
