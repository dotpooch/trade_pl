# encoding: utf-8

class Global

  class << self
    
    def format_string(_string)
      junk       =  %w{.inc .corp .s.a.sp .company .group .com .sa.de.cv .company .co.inc }
      junk       << %w{.holdings .limited .co.ltd .sa .trust.unit .com .l.p .group.inc .co }
      junk       << %w{.group .inc.com .llc .ojsc .corporation .com.inc .trust.inc .ltd .partners.inc  }
      junk       << %w{.inc.can.com .receipts r.mftr.ltd .international .systems.inc .holdings.inc }

      regex_junk = /#{junk.join("$|")}/
      white_space =  /[^\w]{1,}/
      end_period  =  /\.$/
      
      _string.downcase.gsub(white_space, '.').gsub(end_period, '').gsub(regex_junk, '')
    end

    def regex_alpha_num_decimal;  /[A-Za-z0-9_\.]{1,}/;                                      end
    def regex_accepted_formats;   /json|csv|xml|yaml/;                                      end
    
    def invert_fieldnames_and_types(_model)
      inverse = {}
      _model.kind_of?(String) ? model = _model.capitalize.constantize : model = _model
      model.fields.each do |k,v|
        type = v.options[:type]
        sym  = type.to_s.downcase.to_sym
        inverse[sym] = [] unless inverse.has_key? sym
        inverse[sym] << k
      end
      inverse
    end
    
    def hash_product(_hsh)
      keys    = _hsh.keys
      values  = _hsh.values
      product = values.shift.product(*values)
      product.map {|p| Hash[keys.zip p]}
    end
    
    def select_hash_keys(_hsh, _keys)
      _hsh.select { |k,v| _keys.include? k }
    end

  end

end
