# encoding: utf-8

class YahooReader	  	
  attr_reader :prices

  def initialize(_symbols, _names, _model)
    @model, @prices, @temp_array = _model, [],[]
	date = Price.most_recent_date_by_symbol(_symbols.last) if @model == Price
	date = FillDate.most_recent_date_by_symbol(_symbols.last) if @model == FillDate
	date.nil? ? date = Date.new(2001,1,1) : date = date.date + 1
	read_yahoo(_symbols.last, date) if date < ( Date.today - 1 )
  end

  protected
  
  def assembled_url(_symbol, _date)
    csv_files = "http://ichart.finance.yahoo.com/table.csv?s=#{_symbol}"
	unless _date.nil?
      now       = Date.today
	  csv_files = csv_files + "&a=#{_date.month-1}&b=#{_date.day}&c=#{_date.year}"
	  csv_files = csv_files + "&d=#{now.month-1}&e=#{now.day}&f=#{now.year}"
	  csv_files = csv_files + "&g=d"
	end
	csv_files + "&ignore=.csv"
  end

  def read_yahoo(_symbol, _date)
    url = assembled_url(_symbol, _date)
    open(url) do |file|
      read_csv_file(file)
    end
    #csv_files.remove!
  end
  #yalab & roo are file reading alternatives  

  def file_to_array_of_arrays(_file)
    _file.each_line do |line|
      @line = line
      @temp_array << replace_characters.split("|")
    end
  end
  
  def read_csv_file(_file)
    file_to_array_of_arrays(_file)
    file_keys
    array_of_arrays_to_array_of_hashes
  end

  def remove_blank_arrays
    @temp_array.size.times do
      if @temp_array.last.first == ""
        @temp_array.pop
      else
        break
      end
    end
  end

  def replace_characters
    @line.gsub!(" 0:00:00,$","|")
    @line.gsub!('","',"|")
    @line.gsub!(',$',"|")
    @line.gsub!(',',"|")
    @line.gsub!("\r\n","")
    @line.gsub!("\n","")
    @line.gsub!('"',"")
    @line.gsub!(" ","_")
    @line
  end

  def delete_nils(_params)
    _params.each {|key,value| _params.delete(key) if (value.nil? || value.empty?) }
  end

  def array_of_arrays_to_array_of_hashes
    @temp_array.each do |value|
      hash = Hash[@keys.zip(value)]
      @prices << delete_nils(hash)
      fix_dates
    end
  end

  def file_keys
    @keys = @temp_array.shift.map{|key| key.downcase.to_sym}
  end

  def fix_dates
    if @prices.last.has_key? :date
	  date = @prices.last[:date]
	  date = date.split("-") if date.include? "-"
      date = date.split("/") if date.include? "/"
      @prices.last[:date] = Date.new(date[0].to_i, date[1].to_i, date[2].to_i)
    end
  end

end
