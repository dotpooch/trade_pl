class SecuritiesController < ApplicationController

  def index
    @security_types = Security.updated(true)
  end

  def show
    @security  = Security.find_by_name_or_ticker(params[:id])
    @frequency = {}
    @trades    = []
  end

  def new
    @security = Security.new
  end

  def create
    @securities = SecurityCreator.new(params[:security]).securities
    if @securities
      case @securities.size
      when -1
      when 1
        flash[:success] = "Security Created"
        redirect_to security_path(@securities.first[:stub])
      else
        flash[:success] = "Securities Created"
        render 'index'
      end
    else
      flash[:notice] = "Whoops! There was an Error Saving the Security"
      render 'new'
    end
  end

  def edit
    @security = Security.find_by_name(params[:id])
  end

  def update
    security = Security.new(params[:security])
    if security.update_attributes(params[:user])
      flash[:success] = "Security Updated"
      redirect_to security_path(security.name)
    else
      flash[:notice] = "Whoops! There was an Error Updating the Security"
      render 'edit'
    end
  end

  def destroy
    @security = Security.find_by_name(params[:id])
    @security.destroy
    redirect_to(securities_path)
  end


  def upload
    file = FileUploader.new
    if file.store!(params[:file])
      render action: 'show'
    end
  end


  def upload_d()
    @security = Security.find_by_name(params[:id])
    @security.destroy
    redirect_to(securities_path)
  end

end
