# encoding: utf-8

class Security
  include Mongoid::Document
  include Mongoid::Timestamps

  ### RELATIONSHIPS ###
  belongs_to              :institution,   class_name:'Corporation'
  has_many                :stubs,         class_name:'Stub',    inverse_of: :security

  has_many                :prices,        class_name:'Price',       inverse_of: :security, :dependent => :delete
  has_one                 :price_metric,  class_name:'PriceMetric', inverse_of: :security, :dependent => :delete

  has_many                :orders,        class_name:'Order',       inverse_of: :security#, autosave: true
  has_many                :fills,         class_name:'Fill',        inverse_of: :security#, autosave: true
  has_many                :transactions,  class_name:'Transaction', inverse_of: :security
  has_and_belongs_to_many :trades,        class_name:'Trade',       inverse_of: :securities

  ### FIELDS ###
  field :names,         :type => Array
  field :symbols,       :type => Array
  field :cusips,        :type => Array
  
  field :jottings,      :type => String
  field :market,        :type => String
  field :start_date,    :type => Date
  field :end_date,      :type => Date
  field :last_update,   :type => DateTime
  field :count,         :type => Integer,  :default => 0
  field :adr,           :type => Boolean,  :default => false
  
  ### VALIDATIONS ###

  ### SCOPES ###
  scope :named,  ->(_name) { where(:names => _name) }

  ### INSTANCE METHODS ###
  
  public
  
    def name;    names.last;    end
    def symbol;  symbols.last;  end

    def update_attrs
      attrs = aggregate_data
      update_attributes(attrs)
      join
    end

    def join
      join_prices
      join_institution
    end

    def join_prices
      Price.join_security(self)
    end
    
    def join_institution
      institution = institution_found?
      institution.equities << self if institution
    end
    
    def institution_found?
      Corporation.named(name).first
    end

    def aggregate_data
      Price.aggregated_data(names.last)
    end

  private

  
  ### CLASS METHODS ###

  class << self

    public
    
      def updated(_rebuild = false)
        _rebuild ? rebuild : check_for_updates
		all
      end

      def make_all(_names)
        _names.each do |name|
          attributes = Price.aggregated_data(name)
          #Price.named(name).each do |p|
            #attributes.merge!(p.security_attributes)
            create_security(name, attributes)
          #end
        end
      end

      def rejoin_institutions
        all.each { |security| security.join_institution }
      end

      def check_for_updates
        new_prices? ? append_new_prices(last_update) : index_types
      end

      def new_prices?
        last_update != Price.most_recent
      end

      def last_update
        update_all if new_securities?
        most_recent_update
      end

      def new_securities?
        where(:last_update => nil).count > 0
      end

      def most_recent_update
        all.distinct(:last_update).sort.last
      end

      def append_new_prices(_last_update)
        names = Price.where(:updated_at.gte => _last_update, :security_id => nil).distinct(:names)
        update_securities(names)
      end

      def update_all
        all.each { |security| security.update_attrs }
      end

      def rebuild
        purge_all_and_prices
        make_all(Price.unique_names)
      end

      def purge_all_and_prices
        Price.purge_securities
      end
    
      def updated_price_metrics
        PriceMetric.updated
        all.each { |security| security.update_price_metrics }
        index_types
      end

      def index_types
        types = self.all.distinct(:_type)
        types.sort_by { |type| type.constantize.all.count }
        types.map {|type| {plural_sym(type) => get_class(type)} }
      end
      
      def plural_sym(_class)
        _class.downcase.pluralize.to_sym
      end
      
      def get_class(_class)
        securities = _class.constantize.all.entries.sort_by { |i| i.names.last }
      end


      def update(_search, _attributes)
        security = where(_search).first
        security.update_attributes(_attributes)
      end
        
    private
    
      def create_security(_name, _attributes)
        security = named(_name).first
        security = create(_attributes) if security.nil?
      end

      def join_all_prices(_security_names)
        _security_names.each do |name|
          security = where(:names => name).first
          security.join_prices unless security.nil?
        end
      end
 
  end
end
