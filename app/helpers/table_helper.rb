module TableHelper

  ### SORTING ###
  def sort_link(title, column, options = {})
    condition = options[:unless] if options.has_key?(:unless)
    sort_dir = params[:d] == 'up' ? 'down' : 'up'
    link_to_unless condition, title, request.parameters.merge( {:c => column, :d => sort_dir} )
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  ### TABLES ###
  
  ### TABLE HEAD ###
  def thead(_data)
    content_tag(:thead, _data)
  end

  def th(_class, _data)  
    class_text = "list_item_#{_class}_#{_data.gsub(" ","_")}"
    content_tag(:th, _data, class: class_text )  
  end

  def th_deci(_class, _deci, _precision)
    data = number_to_human(_deci, precision: _precision, separator: '.')
    th(_class, data)
  end

  def th_money(_class, _deci, _precision)
    data = money(_deci, _precision)
    th(_class, data)
  end


  ### TABLE ROW ###
  def tr(_data)
    content_tag(:tr, _data)
  end


  ### TABLE DATA ###
  def td(_data)
    content_tag(:td, _data)
  end

  def td_money(_cur, _deci)
    data = money(_cur, _deci)
    td(data)
  end

  def td_percent(_perc, _mult, _deci)
    data = percent(_perc, _mult, _deci)
    td(data)
  end
  
  def td_big_int(_int)
    data = number_to_human(_int, precision: 3, separator: '.', :units => @units)
    td(data)
  end
  
  def td_int(_int)
    data = number_with_delimiter(_int.to_i, delimiter: ',')
    td(data)
  end

  def td_deci(_deci,_precision)
    data = number_to_human(_deci, precision: _precision, separator: '.')
    td(data)
  end

  def td_long_date(_date)
    data = long_date(_date)
    td(data)
  end

  def td_short_date(_date)
    data = short_date(_date)
    td(data)
  end

end
=begin
<table class="table table-striped table-bordered table-condensed">
<th class="list_item_price_date">date</th>
<td class="list_item_price_date"><%= price.date %></td>

content_tag(:div, content_tag(:p, "Hello world!"), class: "strong") <div class="strong"><p>Hello world!</p></div>
content_tag("select", options, multiple: true)                <select multiple="multiple">...options...</select>
=end

