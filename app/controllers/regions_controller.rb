class RegionsController < ApplicationController
  require_role 'admin'

  # GET /regions
  def index
    @regions = Region.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /regions/new
  def new
    @region = Region.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /regions/1/edit
  def edit
    @region = Region.find(params[:id])
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /regions
  def create
    lines = params[:region_info].split(/\r\n/)
    lines.each do |line|
      # split fields and remove leading and trailing whitespace
      details = line.split(/,/)
      5.times do |i|
        details[i].strip! unless details[i].blank?
      end
      
      # either find the region or create it
      region = Region.find_or_create_by_name(details[0])
      
      # update relevant information
      region.director = details[1]
      region.phone = details[2]
      region.mobile_phone = details[3]
      region.email = details[4]
      region.save
    end

    respond_to do |format|
      if !lines.empty?
        flash[:notice] = 'Region(s) added successfully.'
        format.html { redirect_to(regions_path) }
      else
        flash[:error] = 'You did not enter any region information.'
        format.html { render :action => 'new' }
      end
    end
  end

  # PUT /regions/1
  def update
    @region = Region.find(params[:id])

    respond_to do |format|
      if @region.update_attributes(params[:region])
        flash[:notice] = 'Region was successfully updated.'
        format.html { redirect_to(regions_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /regions/1
  def destroy
    @region = Region.find(params[:id])
    @region.destroy

    flash[:notice] = 'Region deleted successfully.'

    respond_to do |format|
      format.html { redirect_to(regions_url) }
    end
  end
end
