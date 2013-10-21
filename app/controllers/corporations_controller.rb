class CorporationsController < ApplicationController

#CorporationsController.instance_variable_get("@name")
#CorporationsController.instance_variable_set
#@model = key.capitalize
#@model.constantize

  def index
    @corps = Corporation.index
  end

  def show
    @corp = Corporation.stubbed(params[:id]).first
    @corp ? render(:show) : redirect_to(companies_path)
  end

  def new
    @corp = Corporation.new
  end

  def edit
    @corp = Corporation.stubbed(params[:id]).first
    @corp ? render(:edit) : redirect_to(companies_path)
  end

  def update
    @corp = Corporation.find_by_name(params[:id])
    if @corp.update(params[:issuer])
      flash[:success] = "Update: Successful"
      redirect_to @option
    else
      flash[:notice] = "Update: Error"
      render :edit
    end
  end

  def destroy
    @corp = Corporation.find_by_name(params[:id])
    @corp.destroy
    redirect_to(corporations_path)
  end

end
