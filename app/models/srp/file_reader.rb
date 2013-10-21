# encoding: utf-8

class FileReader
  attr_reader :output  

  def initialize(_model, _file)
    @model, @output, @temp_array = _model, [],[]
    read_file(_file)
    @output
  end

  protected

  def read_file(_file)
    local_address = "/home/scott/ruby/trade/public"
    file = FileUploader.new
    if file.store! _file
      @file = local_address + file.to_s 
      read_txt_file 
    end
    file.remove!
  end
  #yalab & roo are file reading alternatives

  def read_txt_file
    file_to_array_of_arrays
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

  def file_to_array_of_arrays
    File.open(@file).each do |line|
      @line = line
      @temp_array << replace_characters.split("|")
    end
  end

  def delete_nils(_params)
    _params.each {|key,value| _params.delete(key) if (value.nil? || value.empty?) }
  end

  def array_of_arrays_to_array_of_hashes
    @temp_array.each do |value|
      hash = Hash[@keys.zip(value)]
      hash[:model] = @model
      @output << delete_nils(hash)
      fix_dates
    end
  end

  def file_keys
    @keys = @temp_array.shift.map{|key| key.downcase.to_sym}
  end

  def fix_dates
    if @output.last.has_key? :date
      date = @output.last[:date].split("/")
      date[2].to_i < 25 ? date[2] = date[2].to_i + 2000 : date[2] = date[2].to_i + 1900 unless date[2].to_s.size == 4
      @output.last[:date] = Date.new(date[2].to_i, date[0].to_i, date[1].to_i)
    end
  end

end
