class RoomsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => false

  skip_before_filter :verify_authenticity_token, :only => :auto_complete_for_room

  # GET /rooms
  def index
    @selected_event = params[:event_id] ? params[:event_id] : Event.active_event.id
    @rooms = Room.find(:all, :conditions => "event_id = #{@selected_event}", :order => "name asc")
    @events = Event.get_events

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /rooms/new
  def new
    @room = Room.new
    @events = Event.get_events
    @selected_event = Event.active_event.id

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /rooms
  def create
    lines = params[:room_info].split(/\r\n/)
    lines.each do |line|
      unless line.blank?
        line.strip!
        # either find the room or create it
        room = Room.find(:first, :conditions => "name = '#{line}' and event_id = #{params[:event_id]}")
        if room.nil?
          # create new room
          room = Room.new
          room.name = line
          room.event_id = params[:event_id]
          room.save
        end
      end
    end

    respond_to do |format|
      if !lines.empty?
        flash[:notice] = 'Room(s) added successfully.'
        format.html { redirect_to(rooms_path) }
      else
        flash[:error] = 'You did not enter any room information.'
        format.html { render :action => 'new' }
      end
    end
  end

  # GET /rooms/1/edit
  def edit
    @room = Room.find(params[:id])

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # PUT /rooms/1
  def update
    @room = Room.find(params[:id])
    @room.name = params[:room][:name]

    respond_to do |format|
      if @room.save
        flash[:notice] = 'Room was successfully updated.'
        format.html { redirect_to(rooms_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /rooms/1
  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    
    flash[:notice] = 'Room deleted successfully.'

    respond_to do |format|
      format.html { redirect_to(rooms_url) }
    end
  end

  def auto_complete_for_room
    typed = ''
    params['participant_registration'].each do |key,value|
      id = key
      typed = value['room']
    end

    @rooms = Array.new
    unless params['building_id'].blank? or typed.blank?
      sql = "select room,count(room) as count from participant_registrations where building_id = #{params['building_id']} and room like '%#{typed}%' group by room;"
      r = ActiveRecord::Base.connection.execute(sql)

      r.each_hash do |row|
        @rooms.push(row)
      end
    end
  end
end