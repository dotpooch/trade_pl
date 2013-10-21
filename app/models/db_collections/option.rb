# encoding: utf-8

class Option
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###
  before_save :format_commitment, :create_tickers

  ### RELATIONSHIPS ###
  belongs_to :corp,    class_name: 'Corporation',   inverse_of: :options

  ### FIELDS ###
  field :s,   :type => String,  :as => :symbol
  field :ws,  :type => String,  :as => :whet_symbol
  field :ts,  :type => String,  :as => :traditional_symbol
  field :wts, :type => String,  :as => :whet_traditional_symbol
  field :os,  :type => String,  :as => :option_symbol
  field :us,  :type => String,  :as => :underlying_symbol
  field :n,   :type => String,  :as => :name
  field :an,  :type => String,  :as => :alt_name
  field :c,   :type => Money,   :as => :commitment
  field :s,   :type => Money,   :as => :strike_price
  field :ey,  :type => Integer, :as => :expiration_year
  field :em,  :type => Integer, :as => :expiration_month
  field :ed,  :type => Integer, :as => :expiration_day
  
  ### VALIDATIONS ###

  ### SCOPES ###

  ### INSTANCE METHODS ###

  def downcase_commitment
    commitment = commitment.downcase if commitment.present?
    case commitment
    when "call", "c"
      self.commitment = "c"
    when "put", "p"
      self.commitment = "p"
    else
      self.commitment = nil
    end
  end
  
  def create_tickers
    set_whet_symbol
    set_whet_traditional_symbol
    set_occ_symbol
    set_occ_traditional_symbol
  end
  
  def set_whet_symbol
    self.whet_symbol = "#{underlying_symbol}.#{format_expiration}.#{commitment}.#{format_strike}"
  end

  def set_occ_symbol
    self.symbol = whet_symbol.inject(""){|string,i|string << i}
  end
  
  def set_whet_traditional_symbol
    self.whet_tradional_symbol = "#{option_symbol}.#{convert_month}.#{convert_strike}"
  end

  def set_occ_traditional_symbol
    self.traditional_symbol = whet_traditional_symbol.inject(""){|string,i|string << i}
  end

  def format_expiration;  "#{format_year}.#{format_month}.#{format_day}";  end
  def format_year;         expiration_year.to_s[-2,2];                     end
  def format_month;        format_int_r(expiration_month, 2);              end
  def format_day;          format_int_r(expiration_day, 2);                end

  def format_int_r(_int, _digits)
    string = create_digits(_digits)
    string << _int
    string[-_digits, _digits]
  end

  def format_int_l(_int, _digits)
    _int.to_s << create_digits(_digits)
    _int[0, _digits]
  end

  def create_digits(_digits)
    _digits.inject(''){|digits, i| digits << 0.to_s}
  end

  def format_commitment
    self.commitment.down_case
  end

  def format_strike
    strike  = strike_price.to_s.split(".")
    price   = format_int_r(strike.shift,5)
    decimal = strike.empty? ? "000" : format_int_l(strike,3)
    "#{price}.#{decimal}"
  end
  
  def convert_month
    commitment == "c" ? letter_codes = ("a".."l").to_a : letter_codes = ("m".."x").to_a
    get_code(month, letter_codes, 0, 1)
  end
  
  def convert_strike
   if strike = strike.to_i
      letter_codes = ("a".."t").to_a
      get_code(strike_price, letter_codes, 0, 5)
    else
      letter_codes = ("u".."z").to_a
      get_code(strike_price, letter_codes, 2.5, 5)
    end
  end
  
  def get_code(_look_up_value, _letter_codes, _start, _increment)
    code = {}
    key = _start
    while key < _look_up_value
      _letter_codes.each do |letter|
        key += _increment
        code[key] = letter
      end
    end
    code[_look_up_value].nil? ? "?" : code[_look_up_value]
  end

  ### CLASS METHODS ###

  class << self
  end

end

=begin

#### NAMING CONVENTIONS ####

## New Symbols
Symbol (MSFT, max. 6 characters)
Yr (06)
Mo (03)
Day (18)
C/P (C)
Explicit Strike (00047)
Decimal (500)
This uses no decimals at all

## Old Symbols

SYMBOL+MONTH+STRIKE

Expiration Month Codes
Month|Call|Put
January|A|M
February|B|N
March|C|O
April|D|P
May|E|Q
June|F|R
July|G|S
August|H|T
September|I|U
October|J|V
November|K|W
December|L|X

Strike Price Codes
Code|Strike Prices
A|5|105|205|305|405|505
B|10|110|210|310|410|510
C|15|115|215|315|415|515
D|20|120|220|320|420|520
E|25|125|225|325|425|525
F|30|130|230|330|430|530
G|35|135|235|335|435|535
H|40|140|240|340|440|540
I|45|145|245|345|445|545
J|50|150|250|350|450|550
K|55|155|255|355|455|555
L|60|160|260|360|460|560
M|65|165|265|365|465|565
N|70|170|270|370|470|570
O|75|175|275|375|475|575
P|80|180|280|380|480|580
Q|85|185|285|385|485|585
R|90|190|290|390|490|590
S|95|195|295|395|495|595
T|100|200|300|400|500|600
U|7.5|37.5|67.5|97.5|127.5|157.5
V|12.5|42.5|72.5|102.5|132.5|162.5
W|17.5|47.5|77.5|107.5|137.5|167.5
X|22.5|52.5|82.5|112.5|142.5|172.5
Y|27.5|57.5|87.5|117.5|147.5|177.5
Z|32.5|62.5|92.5|122.5|152.5|182.5

=end
