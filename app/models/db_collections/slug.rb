# encoding: utf-8

class Slug
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###

  ### RELATIONSHIPS ###
  belongs_to :security, class_name: 'Security', inverse_of: :name_list
  belongs_to :trade,    class_name: 'Trade',    inverse_of: :name
  
  ### FIELDS ###
  field :app_generated_slugs,  :type => Array
  field :user_created_slugs,   :type => Array

  ### METHODS ###
  
  ### INSTANCE METHODS ###

  public
  
    def slug
	  user_created_slugs.nil? ? app_generated_slugs.last : user_created_slugs.last
	end

  ### CLASS METHODS ###

  class << self
  
    def make(_obj)
	  @obj = _obj
	  potential_slugs = send(obj_slug_method, @obj)
	  manufacture_slug(potential_slugs)
	  @slug.slug
    end
  
    def obj_slug_method
	  obj_class + "_slug"
	end
  
    def stub_exists?(_name)
      Stub.where(:name => _name).exists?
    end

	def join
	  @slug.relationship = @obj
	end

	def relationship
	  obj_class.constantize
	end
	
	def obj_class
	  @obj.class.name.downcase
	end
	
	def manufacture_slug(_potential_slugs)
	  @slug = find_or_create_by(app_generated_slugs:_potential_slugs)
	  #@slug.app_generated_slugs << _potential_slugs
	  @slug.app_generated_slugs.uniq
	  @slug.save
	end
	
	def corporation_slug(_corporation)
      junk       =  %w{.inc .corp .s.a.sp .company .group .com .sa.de.cv .company .co.inc }
      junk       << %w{.holdings .limited .co.ltd .sa .trust.unit .com .l.p .group.inc .co }
	  junk       << %w{.group .inc.com .llc .ojsc .corporation .com.inc .trust.inc .ltd .partners.inc  }
      junk       << %w{.inc.can.com .receipts r.mftr.ltd .international .systems.inc .holdings.inc }

      regex_junk = /#{junk.join("$|")}/
      white_space =  /[^\w]{1,}/
      end_period  =  /\.$/
      
	  names = []
	  _corporation.names.each do |name|
        names << name.downcase.gsub(white_space, '.').gsub(end_period, '').gsub(regex_junk, '').gsub('.', '-')
      end
	  names
    end
  
    def price_slug(_price)
	  #price.
	#tickers +date
	end 	

def random
      i = 0 
      begin
        i += 1
        #adj  = RandomWord.adjs.next  #=> "pugnacious"
        #noun = RandomWord.nouns.next #=> "audience"
        #word = "#{adj}_#{noun}"

        #word_1 = RandomWordGenerator.word
        word_1 = RandomWord.nouns.next
        begin
          word_2 = RandomWord.nouns.next
          #word_2 = RandomWordGenerator.word
        end until word_1[0,1] != word_2[0,1]
        begin
          word_3 = RandomWord.nouns.next
          #word_3 = RandomWordGenerator.word
        end until (word_1[0,1] != word_2[0,1] || word_2[0,1] != word_3[0,1])
        
        word   = "#{word_1}.#{word_2}"#_#{word_3}
        BREAK if  i == 100000
      end until stub_exists?(word) == false
      Stub.create(:name => word)
      word

end  
  end

end
