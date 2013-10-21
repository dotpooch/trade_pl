# encoding: utf-8

class Stub
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###

  ### RELATIONSHIPS ###
  has_and_belongs_to_many :stubs, class_name: 'Security', inverse_of: :ticker_list
  belongs_to :security, class_name: 'Security', inverse_of: :name_list
  belongs_to :trade,    class_name: 'Trade',    inverse_of: :name
  
  ### FIELDS ###
  field :name,  :type => String,  :as => "stub"

  ### METHODS ###
  
  ### CLASS METHODS ###

  class << self
  
    def make
      i = 0 
      begin
        i += 1
        #adj  = RandomWord.adjs.next  #=> "pugnacious"
        #noun = RandomWord.nouns.next #=> "audience"
        #word = "#{adj}_#{noun}"

        word_1 = RandomWordGenerator.word
        begin
          word_2 = RandomWordGenerator.word
        end until word_1[0,1] != word_2[0,1]
        begin
          word_3 = RandomWordGenerator.word
        end until (word_1[0,1] != word_2[0,1] || word_2[0,1] != word_3[0,1])
        
        word   = "#{word_1}.#{word_2}"#_#{word_3}
        BREAK if  i == 100000
      end until stub_exists?(word) == false
      Stub.create(:name => word)
      word
    end
  
    def stub_exists?(_name)
      Stub.where(:name => _name).exists?
    end

  end

end
