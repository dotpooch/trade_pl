# encoding: utf-8

class Accuracy
  include Mongoid::Document
  include Mongoid::Timestamps
  

  ### RELATIONSHIPS ###


  ### FIELDS ###
  field :stub,    :type => String
  field :names,   :type => Array
  field :symbols, :type => Array
  field :cusips,  :type => Array

  field :stub,             :type => String
  field :transaction_stub, :type => String
  field :trade_stub,       :type => String

  field :index, :type => Integer
  field :date,  :type => Date

  field :open,  :type => Money
  field :high,  :type => Money
  field :low,   :type => Money
  field :close, :type => Money

  ### SCOPES ###

  ### QUERIES ###

  ### VALIDATIONS ###

  ### INSTANCE METHODS ###

  public
  
    def name;    names.last;    end
    def symbol;  symbols.last;  end
  
  private
  
  
  ### CLASS METHODS ###
  
  class << self

  public
  
    
    def build
      delete_all
      Trade.all.each do |trade|
        transactions = Transaction.where(:ts => trade.stub).entries
        transactions.each do |transaction|
         #d {transaction}
          price = transaction.net_price.to_f
          date = transaction.date
          prices = Price.where(:symbols => trade.symbol, :d.gte => date).asc(:d).limit(250)
          i = 0
          prices.each do |p|

            index = i += 1
            i_open_return  = p.o.to_f / price.abs - 1
            i_high_return  = p.h.to_f / price.abs - 1
            i_low_return   = p.l.to_f / price.abs - 1
            i_close_return = p.c.to_f / price.abs - 1

            hsh = {
            :stub    => Stub.make,
            :transaction_stub  => transaction.stub,
            :trade_stub        => trade.stub,
            :names   => p.names,
            :symbols => p.symbols,
            :cusips  => p.cusips,
            :date   => date,
            :index  => index,
            :open   => i_open_return,
            :high   => i_high_return,
            :low    => i_low_return,
            :close  => i_close_return
            }
         
            create(hsh)
            d {i}
          end
        end
      end
    end



  private
  

  end
  
end

