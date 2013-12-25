class RegisterableItemsController < ApplicationController
  require_role 'admin', :except => [ 'show' ]
  
  # GET /registerable_items
  def index
    @registerable_items = RegisterableItem.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /registerable_items/1
  def show
    @registerable_item = RegisterableItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /registerable_items/new
  def new
    @registerable_item = RegisterableItem.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /registerable_items/1/edit
  def edit
    @registerable_item = RegisterableItem.find(params[:id])
  end

  # POST /registerable_items
  def create
    @registerable_item = RegisterableItem.new
    @registerable_item.name = params[:registerable_item][:name]
    @registerable_item.description = params[:registerable_item][:description]
    @registerable_item.price = params[:registerable_item][:price]

    respond_to do |format|
      if @registerable_item.save
        flash[:notice] = 'Registerable item was successfully created.'
        format.html { redirect_to(registerable_items_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /registerable_items/1
  # PUT /registerable_items/1.xml
  def update
    @registerable_item = RegisterableItem.find(params[:id])
    @registerable_item.name = params[:registerable_item][:name]
    @registerable_item.description = params[:registerable_item][:description]
    @registerable_item.price = params[:registerable_item][:price]

    respond_to do |format|
      if @registerable_item.save
        flash[:notice] = 'Registerable item was successfully updated.'
        format.html { redirect_to(registerable_items_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /registerable_items/1
  # DELETE /registerable_items/1.xml
  def destroy
    @registerable_item = RegisterableItem.find(params[:id])
    @registerable_item.destroy
    flash[:notice] = 'Registerable item was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to(registerable_items_url) }
    end
  end
end