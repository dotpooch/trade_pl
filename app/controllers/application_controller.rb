class ApplicationController < ActionController::Base
  protect_from_forgery
  #use_vanity :current_user

  def read_params(_params)
    #key = params.keys.inject("") {|string,key| string = key if key.include?('_id')}

    controller          = params[:controller].split('/')
    parent              = controller.shift.singularize
    child               = controller.shift.singularize
    grandchild          = controller.shift.singularize

    @parent_stub        = params["#{parent}_id".to_sym]
    @child_stub         = params["#{child}_id".to_sym]
    @grandchild_stub    = params["#{grandchild}_id".to_sym]

    @parent_model       = parent.capitalize.constantize
    @child_model        = child.capitalize.constantize
    @grandchild_model   = grandchild.capitalize.constantize

    @child_method       = child.pluralize
    @grandchild_method  = grandchild.pluralize
    
    @parent       = @parent_model.stubbed(@parent_stub).first
    @childs       = @parent.send(@child_method)
    @grandchilds  = @child.send(@grandchild_method)
  end

end
