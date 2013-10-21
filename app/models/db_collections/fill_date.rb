# encoding: utf-8

class FillDate
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###
  before_save       :set_attributes, :create_stub

  ### RELATIONSHIPS ###
  has_many :prices,       class_name:'Price',       inverse_of: :fill_date
  has_many :fills,        class_name:'Fill',        inverse_of: :fill_date
  has_many :transactions, class_name:'Transaction', inverse_of: :fill_date

  has_and_belongs_to_many :trades,       class_name:'Trade', inverse_of: :fill_date
  has_and_belongs_to_many :trade_starts, class_name:'Trade', inverse_of: :start_fill_date
  has_and_belongs_to_many :trade_ends,   class_name:'Trade', inverse_of: :end_fill_date

  ### FIELDS ###
  field :d,    :type => Date,    :as => 'date'
  field :ad,   :type => String,  :as => 'alt_date'
  field :y,    :type => Integer, :as => 'year'
  field :q,    :type => Integer, :as => 'quarter'

  field :m,    :type => Integer, :as => 'month'
  field :moq,  :type => Integer, :as => 'month_of_quarter'

  field :woy,  :type => Integer, :as => 'week_of_year'
  field :woq,  :type => Integer, :as => 'week_of_quarter'
  field :wom,  :type => Integer, :as => 'week_of_month'

  field :doy,  :type => Integer, :as => 'day_of_year'
  field :doq,  :type => Integer, :as => 'day_of_quarter'
  field :dom,  :type => Integer, :as => 'day_of_month'
  field :dow,  :type => Integer, :as => 'day_of_week'

  field :dbmc, :type => Boolean, :as => 'day_before_market_closed'
  field :damc, :type => Boolean, :as => 'day_after_market_closed'
  field :wwmc, :type => Boolean, :as => 'week_with_market_closed'

  ### VALIDATIONS ###
  validates :d,  :presence => {:on => :create}

  ### SCOPES ###
  scope :ascending,    all.asc(:d)
  scope :descending,   all.desc(:d)
  scope :by_date,     ->(_date) { where(:d => _date) }
  scope :with_trades,  where(:trade_ids.ne => [])

  ### INSTANCE METHODS ###
 
  def create_stub
    self.ad = "#{year}.#{month}.#{day_of_month}" unless alt_date
  end

  def set_attributes
    set_year              if self.year.nil?
    set_month             if self.month.nil?
    set_week_of_year      if self.week_of_year.nil?
    set_day_of_year       if self.day_of_year.nil?
    set_day_of_month      if self.day_of_month.nil?
    set_day_of_week       if self.day_of_week.nil?
    set_quarter           if self.quarter.nil?
    set_month_of_quarter  if self.month_of_quarter.nil?
    set_week_of_quarter   #if self.week_of_quarter.nil?
    set_week_of_month     #if self.week_of_month.nil?
  end

  protected

  def set_year;         self.year          = date.year.to_i   end
  def set_month;        self.month         = date.month.to_i  end
  def set_day_of_year;  self.day_of_year   = date.yday.to_i   end
  def set_day_of_month; self.day_of_month  = date.mday.to_i   end
  def set_day_of_week;  self.day_of_week   = date.cwday.to_i  end
  def set_week_of_year; self.week_of_year  = date.cweek.to_i  end

  def set_week_of_month
    w = cweek(year, month, day_of_month)
    unless month == 1
      case month
      when 3; Date.leap?(year) ? weeks=calc_week_of_month(w,year,3,29):weeks=calc_week_of_month(w,year,3,28)
      when 2,4,6,8,9,11;  weeks = calc_week_of_month(w,year,month,31)
      when 5,7,10,12;     weeks = calc_week_of_month(w,year,month,30)
      end
      weeks = weeks_in_previous_month(year, month) if weeks == 0
    end
    self.week_of_month = weeks
  end

  def weeks_in_previous_month(_year, _month)
    case _month
    when 2; cweek(_year, 1, 31)
    when 3; Date.leap?(_year) ? (cweek(_year,2,29) - cweek(_year,1,31)) : (cweek(_year,2,28) - cweek(_year,1,31))
    when 4; Date.leap?(_year) ? (cweek(_year,3,31) - cweek(_year,2,29)) : (cweek(_year,3,31) - cweek(_year,1,28))
    when 6,8,9,11; cweek(_year,_month-1, 31) - cweek(_year,_month-2,30)
    when 5,7,10,12;  cweek(_year,_month-1, 30) - cweek(_year,_month-2,31)
    end
  end

  def calc_week_of_month(_week_of_year, _year, _month, _day)
    _week_of_year - cweek(_year, _month-1, _day)
  end

  def cal_week(_year, _month, _day)
    Date.new(_year, _month, _day).cweek
  end

  def cweek(_year, _month, _day)
    w =  Date.new(_year, _month, _day).cweek
    w = (Date.new(_year, _month, _day-5).cweek + 1) if (w == 1 && month == 12)
    w
  end

  def set_month_of_quarter
    case month
    when 1,4,7,10; self.month_of_quarter = 1
    when 2,5,8,11; self.month_of_quarter = 2
    when 3,6,9,12; self.month_of_quarter = 3
    end
  end

  def set_quarter
    case month
    when 1,2,3; self.quarter = 1
    when 4,5,6; self.quarter = 2
    when 7,8,9; self.quarter = 3
    else;       self.quarter = 4
    end
  end

  def set_week_of_quarter
    w_of_y = cweek(year, month, day_of_month)

    case quarter
    when 1
      qtr_week =  w_of_y
    when 2
      qtr_week = (w_of_y - cweek(year, 3, 31))
      qtr_week =  w_of_y if qtr_week == 0
    when 3
      qtr_week = (w_of_y - cweek(year, 6, 30))
      qtr_week = (w_of_y - cweek(year, 3, 31)) if qtr_week == 0
    when 4
      qtr_week = (w_of_y - cweek(year, 9, 30))
      qtr_week = (w_of_y - cweek(year, 6, 30)) if qtr_week == 0
    end
    self.week_of_quarter = qtr_week
  end

  ### CLASS METHODS ###
  
  class << self

    def map_queriable_fields
      model, criteria  = FillDate, {}
      types  = Global.invert_fieldnames_and_types(model)
      types  = types.select { |k,v| [:integer,:boolean].include?(k) }
      fields = types.inject([]) {|array,i| array << i[1] }.flatten
      fields.each do |field|
        field            = field.to_sym
        criteria[field]  = model.all.only(field).distinct(field)
      end
      #criteria.each_value { |v| v.unshift(nil).uniq! }
      criteria
    end
  
    def assemble_joins
      join_fills
      join_transactions
      join_trades
    end
  
    def join_fills;         join("fill");         end
    def join_transactions;  join("transaction");  end
    def join_trades;        join("trade");        end

    def join(_model)
      model       = _model.capitalize.constantize
      types       = Global.invert_fieldnames_and_types(_model)
      types[:datetime].nil? ? date_fields = types[:date] : date_fields = types[:datetime]
      model.all.each do |i|
        date_fields.each do |field|
          #d {i} if i.send(field).nil?
          date = i.send(field).to_date

          fill_date = by_date(date).first
          if fill_date.nil?
            begin
              date = i.send(field).to_date
              
              y = date.year.to_i
              m = date.month.to_i
              d = date.mday.to_i

              case date.cwday.to_i
              when 5,6;        d -= 1
              when 7,1,2,3,4;  d += 1
              end

              new_date = DateTime.new(y,m,d)
              i.send("#{field}=", new_date) unless i.send(field).include? new_date
              i.save

              fill_date = self.by_date(date).first

            end until !fill_date.nil?
          end

          i.fill_date  =  fill_date if i.fields.has_key?("fill_date_id")
          if i.fields.has_key?("fill_date_ids")
            i.fill_dates      << fill_date
            i.start_fill_date << fill_date if field == "start_date"
            i.end_fill_date   << fill_date if field == "end_date"
          end
          i.save		  
        end
      end
    end

    def update_stubs
      FillDate.ascending.each do |date|
        @date = date
        @date.save
      end
    end

  end

end
