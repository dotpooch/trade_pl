# encoding: utf-8

class FillTime
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ### RELATIONSHIPS ###
  has_many :prices,       class_name:'Price',       inverse_of: :date
  has_many :fills,        class_name:'Fill',        inverse_of: :date
  has_many :transactions, class_name:'Transaction', inverse_of: :date

  ### FIELDS ###
  field :time,          :type => Time
  field :minute,        :type => Integer
  field :five_minutes,  :type => Integer
  field :quarter_hour,  :type => Integer
  field :half_hour,     :type => Integer
  field :hour,          :type => Integer

  mount_uploader :file, FileUploader

  ### METHODS ###

  def self.create_times
    set_defaults
    (60*24).times do
      increment_data
      set_field_data
    end
  end

  protected

  def set_defaults
    @minute, @five, @quarter, @half, @hour, @time = 0, 1, 1, 1, 1, Time.new(0)
  end

  def increment_data
    increment_time
    increment_minute
    increment_five
    increment_quarter
    increment_half
    increment_hour
  end

  def set_field_data
    set_time
    set_minute
    set_five
    set_quarter
    set_half
    set_hour
  end

  def increment_time;      @time     = @time + 60;                        end
  def increment_minute;    @minute   = (@minute + 1) % 60;                end
  def increment_five;      @five     = @five + 1    if @minute % 5  == 0; end
  def increment_quarter;   @quarter  = @quarter + 1 if @minute % 15 == 0; end
  def increment_half;      @half     = @half + 1    if @minute % 30 == 0; end
  def increment_hour;      @hour     = @hour + 1    if @minute % 60 == 0; end

  def set_time;     self.time         = @time;     end
  def set_minute;   self.minute       = @minute;   end
  def set_five;     self.five_minutes = @five;     end
  def set_quarter;  self.quarter_hour = @quarter;  end
  def set_half;     self.half_hour    = @half;     end
  def set_hour;     self.hour         = @hour;     end

end
