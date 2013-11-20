# encoding: utf-8

class InvestmentReturns
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###

  ### RELATIONSHIPS ###

  ### FIELDS ###
  field :stub,    :type => String
  field :names,   :type => Array
  field :symbols, :type => Array
  field :cusips,  :type => Array

  field :trade_stub,        :type => String
  field :transaction_stub,  :type => String
  field :transaction_date,  :type => Date
  field :transaction_price, :type => Money
  field :fill_type,         :type => String
  
  field :index,            :type => Hash

  ### INSTANCE METHODS ###

  public

    def name;    names.last    end
    def symbol;  symbols.last  end
    def opens;   get_returns("open")  end
    def highs;   get_returns("high")  end
    def lows;    get_returns("low")   end
    def closes;  get_returns("close") end

  private

    def get_returns(_price)
      ary = []
      index.each { |i| ary << i.last[_price] }
      ary
    end

  ### CLASS METHODS ###
  
  class << self
  
    public

      def average_returns(_qry)
        investment_returns = Investment_Returns.any_of(_qry)

        aggregate_data(investment_returns)
      end
        
      def build
        delete_all
        Trade.all.each do |trade|
          transactions = Transaction.where(:ts => trade.stub).entries
          transactions.each do |transaction|

            price  = transaction.net_price.to_f
            date   = transaction.date

            hsh = {
            :transaction_stub  => transaction.stub,
            :trade_stub        => trade.stub,
  
            :fill_type          => transaction.fill_type,
            :transaction_date   => date,
            :transaction_price  => price
            }

            i = 0
            prices = Price.where(:symbols => trade.symbol, :d.gte => date).asc(:d).limit(250)

            unless prices.empty?
              ids = price_ids(prices.first) 
              hsh.merge(ids) 
             
              prices.each do |p|
                _hsh = {:i => (i += 1) , :date => date.to_s, :p => p, :price => price.abs }
                index[i.to_s] = returns(_hsh)
              end
              hsh[:index] = index
              create(hsh)
            end
          
          end
        end
      end
      
    private

      def aggregate_data(_investment_returns)
        data = { :open => [], :high => [], :low => [], :close => [] }
        _investment_returns.each do |r|
          data[:high]   << r.highs
          data[:open]   << r.opens
          data[:low]    << r.lows
          data[:close]  << r.closes
        end
        data_returns(data)
      end
      
      def data_returns(_data)
        average = {
          :open  => average(_data[:open]),
          :high  => average(_data[:high]),
          :low   => average(_data[:low]),
          :close => average(_data[:close])
          }
        average[:returns] = aggregate_averages(average)
        average
      end

      def aggregate_averages(_data)
        returns_ary, i  = [], 0
        _data[:close].size.times do
          returns_ary << {
            :index  =>  i,
            :open   => _data[:open][i],
            :high   => _data[:high][i],
            :low    => _data[:low][i],
            :close  => _data[:close][i]
            }
          i += 1
        end
        returns_ary
      end

      def average(_ary)
        avg = []
        250.times do
          i =  []
         _ary.each do |series|
            i << series.shift
          end
          avg << i.inject{ |sum, element| sum + element }.to_f / i.size unless empty?
        end
        avg
      end

      def create_returns(_prices)
        ids = price_ids(_prices.first) 
        hsh.merge(ids) 
             
        prices.each do |p|
          _hsh = {:i => (i += 1) , :date => date.to_s, :p => p, :price => price.abs }
          index[i.to_s] = returns(_hsh)
        end
        
        hsh[:index] = index
        create(hsh)
      end  

      def price_ids(_price)
        {
        :stub    => Stub.make,
        :names   => _price.names,
        :symbols => _price.symbols,
        :cusips  => _price.cusips
        }
      end  

      def returns(hsh)
        {
        :index  => hsh[:i],
        :date   => hsh[:date],
        :open_price   => hsh[:p].o.to_s,
        :high_price   => hsh[:p].h.to_s,
        :low_price    => hsh[:p].l.to_s,
        :close_price  => hsh[:p].c.to_s,
        :open   => (hsh[:p].o.to_f / hsh[:price] - 1),
        :high   => (hsh[:p].h.to_f / hsh[:price] - 1),
        :low    => (hsh[:p].l.to_f / hsh[:price] - 1),
        :close  => (hsh[:p].c.to_f / hsh[:price] - 1)
        }
      end  

  end

end
