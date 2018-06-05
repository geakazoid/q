class BuildingsController < ApplicationController
  require_role 'admin'

  # GET /buildings
  def index
    @selected_event = params[:event_id] ? params[:event_id] : Event.active_event.id
    @buildings = Building.find(:all, :conditions => "event_id = #{@selected_event}", :order => "name asc")
    @events = Event.get_events

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /buildings/new
  def new
    @building = Building.new
    @events = Event.get_events
    @selected_event = Event.active_event.id

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /buildings
  def create
    lines = params[:building_info].split(/\r\n/)
    lines.each do |line|
      unless line.blank?
        line.strip!
        # either find the building or create it
        building = Building.find(:first, :conditions => "name = '#{line}' and event_id = #{params[:event_id]}")
        if building.nil?
          # create new building
          building = Building.new
          building.name = line
          building.event_id = params[:event_id]
          building.save
        end
      end
    end

    respond_to do |format|
      if !lines.empty?
        flash[:notice] = 'Building(s) added successfully.'
        format.html { redirect_to(buildings_path) }
      else
        flash[:error] = 'You did not enter any building information.'
        format.html { render :action => 'new' }
      end
    end
  end

  # GET /buildings/1/edit
  def edit
    @building = Building.find(params[:id])

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # PUT /buildings/1
  def update
    @building = Building.find(params[:id])
    @building.name = params[:building][:name]

    respond_to do |format|
      if @building.save
        flash[:notice] = 'Building was successfully updated.'
        format.html { redirect_to(buildings_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /buildings/1
  def destroy
    @building = Building.find(params[:id])
    @building.destroy
    
    flash[:notice] = 'Building deleted successfully.'

    respond_to do |format|
      format.html { redirect_to(buildings_url) }
    end
  end
end
