module LinkHelper

  def show_details_link(_type, _id)
    path = "#{(_type).singularize}_path"
    link_text  = "#{_type.split('_').map(&:capitalize).join(' ')}"
    link_to link_text, send(path, _id), class: "btn"
  end

  def add_more_link(_type, _id)
    path = "#{(_type).singularize}_path"
    link_text  = "Add #{_type.split('_').map(&:capitalize).join(' ')}"
    link_to link_text, send(path, _id), class: "btn btn-link btn-mini"
  end

end
