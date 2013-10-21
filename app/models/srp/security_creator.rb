# encoding: utf-8

class SecurityCreator
  attr_reader :securities

  def initialize(_params)
    Stub.delete_all
    Ticker.delete_all
    Security.delete_all
    @data, @securities  = ReadFileAndOrForm.new(_params).multiple, []
    create_models
  end

  def create_models
    @data.each do |data|
@securities << create_single(data)
    end
  end


#new, same name, same ticker, similar name

#  def self.find_or_create(_params)
#    @ticker = _params[:ticker]
#    TickerCreator.new
#  end

#  def initialize
#    format
#    Ticker.find_or_create_by(ticker: @ticker)
#  end

#  protected
 
#  def format
#    @ticker = @ticker.gsub(/[^0-9A-Za-z]/, '.').gsub('...', '.').gsub('..', '.').downcase
#  end



#  def initialize
 #   self
 # end

  def join_security_and_ticker#(_ticker)
    #ticker = Ticker.find_or_create_by(ticker: _ticker.downcase)
    @ticker.securities << @security unless @ticker.securities.include? @security
    @security.tickers_list << @ticker unless @security.tickers_list.include? @ticker
    @security.tickers << @ticker.ticker unless @security.tickers.include? @ticker.ticker
    @ticker.save
    @security.save
  end

  def join_security_and_stub#(_stub)
    #Stub = StubCreator.new.create(_stub)

    @stub.security = @security   unless @stub.security == @security
    @security.stubs << @stub     unless @security.stubs.include? @stub
    @stub.save
    @security.save
  end

  def create_multiple
    @data.each {|single| @fills << create_single(single)}
  end

  def create_single(_params)
    params = _params

#      hash[:ms_access_ticker] = nil if hash[:ms_access_ticker].nil? || hash[:ms_access_ticker].empty?
#      hash[:description] = nil      if hash[:description].nil? || hash[:description].empty?
#      hash[:notes] = nil            if hash[:notes].nil? || hash[:notes].empty?
#      hash[:marketplace] = nil      if hash[:marketplace].nil? || hash[:marketplace].empty?
#      hash[:type] = nil             if hash[:type].nil? || hash[:type].empty?


    @stub   = StubCreator.new.find_or_create(params[:name])
    @ticker = TickerCreator.new.find_or_create(params)

    @security = @stub.security
    modified = false
  
    if @security.nil?
      @security = Security.new
      modified = true
    end 
    unless @security.ms_access_ticker
      @security.ms_access_ticker = params[:ms_access_ticker]
      modified = true
    end
    unless @security.description
      @security.description      = params[:description]
      modified = true
    end
    unless @security.notes
      @security.notes            = params[:notes]            
      modified = true
    end
    unless @security.marketplace
      @security.marketplace      = params[:marketplace]
      modified = true
    end
    unless @security.names.include? params[:name]
      @security.names           << params[:name]
      modified = true
    end 
    unless @security.type

      @security.type              = params[:type].downcase
      modified = true
    end
    @security.save

    join_security_and_stub#(params[:name])
    join_security_and_ticker#(params[:ticker])

    @security.save
    @security
  end

  def params_empty?(_params)
    empty = true
    _params.each_value do |value|
      unless value.empty?
        empty = false
        break
      end
    end
    empty
  end

  def create(_params)
#Security.delete_all
#Stub.delete_all
#Ticker.delete_all
#Trade.delete_all
#User.delete_all
#Price.delete_all
#BREAK
    @data  = ReadFileAndOrForm.new(_params).multiple
    create_models

  #  @securities = []
  #  read_a_file(_params[:file]) if _params[:file]
  #  _params.delete(:file)
  #  @securities << create_a_single_security(_params) unless params_empty?(_params)
  #  @securities
  end

end

class ReadFileAndOrForm
  attr_reader :multiple
  
  def initialize(_params)
    @multiple = []
    read_file(_params[:file]) if _params[:file]
    read_form(_params)
  end

  def read_file(_file)
    @multiple = FileReader.new(_file).output
  end

  def read_form(_params)
    @multiple << _params unless params_empty?(_params)    
  end

  def params_empty?(_params)
    _params.values.any?{|v| v.nil? || v.size == 0}
  end

end

