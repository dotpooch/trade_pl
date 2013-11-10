class FillsController < ApplicationController

#CorporationsController.instance_variable_get("@name")
#CorporationsController.instance_variable_set
#@model = key.capitalize
#@model.constantize

  def index
    @fills = Fill.all
  end

  def show
    @fill = Fill.where(:s => (params[:id])).first
    @fill ? render(:show) : redirect_to(fills_path)
  end

  def new
    @fill = Fill.new
  end

  def create
    @fill = Fill.create(params[:fill])
    if @fill
      flash[:success] = "Create: Successful"
      render :show
    else
      flash[:notice] = "Create: Error"
      render :new
    end
  end

  def edit
    @fill = Fill.where(:s => (params[:id])).first
    @fill ? render(:edit) : redirect_to(fills_path)
  end

  def update
    @fill = Fill.where(:id => (params[:fill][:id])).first
    if @fill
	  @fill.update_attributes!(params[:fill])
      flash[:success] = "Update: Successful"
      render(:show)
    else
      flash[:notice] = "Update: Error"
      render :edit
    end
  end

  def destroy
    @fill = Fill.where(:stub => (params[:id])).first
    @fill.destroy
    redirect_to(fills_path)
  end

end
