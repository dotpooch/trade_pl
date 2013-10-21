# encoding: utf-8

 class Corporation
  include Mongoid::Document
  include Mongoid::Timestamps

  ### CALLBACKS ###
  before_save :create_stubs

  ### RELATIONSHIPS ###
  has_many  :debts,                class_name:'Debt',             inverse_of: :institution#, autosave: true
  has_many  :preferred_equities,   class_name:'Preferred_Equity', inverse_of: :institution#, autosave: true
  has_many  :equities,             class_name:'Equity',           inverse_of: :institution#, autosave: true
  has_many  :options,              class_name:'Option',           inverse_of: :institution#, autosave: true

  ### FIELDS ###
  field :stubs,    :type => Array
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

    def name;       names.last             end
    def stub;       stubs.last             end
    def old_names;  names[0...-1].reverse  end


    def create_stubs
      self.stubs = names.map { |name| Global.format_string(name) }
    end

    def securities
      relationships = ['equities','options','debts','preferred_equities']
      relationships.sort { |a, b| self.send(b).count <=> self.send(a).count }
    end

    def join
      join_securities
    end

  private

    def join_securities
    F
=begin
      Security.named(names).update_attribute(:corp => self)
      relation = security["_type"].downcase.pluralize
      self.send(security["_type"].downcase.pluralize) = security
      self.stubs = names.map { |name| Global.format_string(name) }
=end
    end
    
    def relation()
      security["_type"].downcase.pluralize
    end

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

    private
  
  end

end
