class DistrictsController < ApplicationController
  require_role 'admin', :except => [:num_teams]

  # GET /districts
  def index
    @districts = District.find(:all, :order => "name")

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /districts/new
  def new
    @district = District.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /districts/1/edit
  def edit
    @district = District.find(params[:id])
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /districts
  def create
    lines = params[:district_info].split(/\r\n/)
    lines.each do |line|
      # split fields and remove leading and trailing whitespace
      details = line.split(/,/)
      6.times do |i|
        details[i].strip! unless details[i].blank?
      end

      # either find the region or create it
      region = Region.find_or_create_by_name(details[1])

      # either find the district or create it
      district = District.find_or_create_by_name(details[0])

      # update relevant information
      district.name = details[0]
      district.director = details[2]
      district.phone = details[3]
      district.mobile_phone = details[4]
      district.email = details[5]
      district.region = region
      district.save
    end

    respond_to do |format|
      if !lines.empty?
        flash[:notice] = 'District(s) added successfully.'
        format.html { redirect_to(districts_path) }
      else
        flash[:error] = 'You did not enter any district information.'
        format.html { render :action => 'new' }
      end
    end
  end

  # PUT /districts/1
  def update
    @district = District.find(params[:id])

    respond_to do |format|
      if @district.update_attributes(params[:district])
        flash[:notice] = 'District was successfully updated.'
        format.html { redirect_to(districts_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /districts/1
  def destroy
    @district = District.find(params[:id])
    @district.destroy
    
    flash[:notice] = 'District deleted successfully.'

    respond_to do |format|
      format.html { redirect_to(districts_url) }
    end
  end

  # GET /districts/num_teams?id=:id
  # TODO: make this cleaner.
  def num_teams
    if (!params[:id].blank?)
      @district = District.find(params[:id])

      respond_to do |format|
        format.html { render :text => @district.num_district_teams }
      end
    else
      render :nothing => true
    end
  end

end
