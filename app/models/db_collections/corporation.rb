# encoding: utf-8

 class Corporation
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###
  #before_save :make_slug

  ### RELATIONSHIPS ###
  has_many  :debts,               class_name:'Debt',             inverse_of: :institution#, autosave: true
  has_many  :preferred_equities,  class_name:'PreferredEquity',  inverse_of: :institution#, autosave: true
  has_many  :equities,            class_name:'Equity',           inverse_of: :institution#, autosave: true
  has_many  :options,             class_name:'Option',           inverse_of: :institution#, autosave: true

  ### FIELDS ###
  field :slug,     :type => String
  field :names,    :type => Array
  field :desc,     :type => String
  field :jottings, :type => String
  
  ### VALIDATIONS ###
  validates_presence_of :names

  ### SCOPES ###
  scope :stubbed,   ->(_name) {where(:stubs  => _name)}
  scope :named,     ->(_name) {where(:names => _name)}

  ### INSTANCE METHODS ###

  public

    def name;       names.last                   end
    def old_names;  names[0...-1].reverse        end
    #def make_slug;  self.slug = Slug.make(self)  end

    def securities
      relationships = ['equities','options','debts','preferred_equities']
      relationships.sort { |a, b| send(b).size <=> send(a).size}
    end

  private
=begin

  ### CLASS METHODS ###
  
  class << self

    public
    
      def index
        index = self.all.map {|corp| get_index_hashes(corp) }
        index.flatten.sort_by { |i| i[:name] }
      end
      
      def get_index_hashes(_corp)
        names    = _corp.names
        stubs    = _corp.stubs

        index = []
        names.size.times do
          hsh = {}
          hsh[:name]     = names.shift
          hsh[:stub]     = stubs.shift
          hsh[:desc]     = _corp.desc
          hsh[:jottings] = _corp.jottings
          hsh[:name]     << " *" unless names.empty?
          index << hsh
        end
        index
      end

      def update_stubs
        self.alpha.each { |company| company.save }
      end
	  
	  def make(_names)
        find_or_create_by(names:_names)
	  end
	  
    private
  
  end
=end

end
