class HousingRoomsController < ApplicationController

  before_filter :login_required
  require_role ['admin','housing_admin']

  # GET /housing_rooms
  def index
    # if we aren't an admin or housing admin we shouldn't be here
    record_not_found and return if !admin? and !housing_admin?

    @housing_rooms = HousingRoom.ordered_by_building_and_room
    @buildings = Building.all(:order => 'name')

    # filter results if we have any filters
    unless session[:status].blank?
      if (session[:status] == 'complete')
        @housing_rooms = @housing_rooms.keycode_complete
        @filter_applied = true
      elsif (session[:status] == 'incomplete')
        @housing_rooms = @housing_rooms.keycode_incomplete
        @filter_applied = true
      end
    end
    unless session[:building_id].blank?
      @housing_rooms = @housing_rooms.by_building(session[:building_id])
      @filter_applied = true
    end

    respond_to do |format|
      format.html
    end
  end

  # POST /housing_rooms/save
  # save values off of housing rooms form
  def save
    # if we aren't an admin or housing admin we shouldn't be here
    record_not_found and return if !admin? and !housing_admin?

    params['housing_room'].each do |id,data|
      room = HousingRoom.find(id)
      room.keycode = data['keycode']
      room.save
    end

    flash[:notice] = 'Key Code information saved successfully.'

    respond_to do |format|
      format.html {
        redirect_to(housing_rooms_url)
      }
    end
  end

  # GET /housing_rooms/filter/?parameters
  # filter housing rooms list based upon passed in filters
  def filter
    # if we aren't an admin or housing admin we shouldn't be here
    record_not_found and return if !admin? and !housing_admin?

    # clear filters if requested
    if params[:clear] == 'true'
      session[:status] = nil
      session[:building_id] = nil

      flash[:notice] = 'All filters have been cleared.'
    else
      # update session values from passed in params
      session[:status] = params[:status] unless params[:status].blank?
      session[:building_id] = params[:building_id] unless params[:building_id].blank?

      # remove filters if none is passed
      session[:status] = nil if params[:status] == 'none'
      session[:building_id] = nil if params[:building_id] == 'none'

      flash[:notice] = 'Filters updated successfully.'
    end

    respond_to do |format|
      format.html {
        redirect_to(housing_rooms_url)
      }
    end
  end

  # GET /housing_rooms/regenerate
  # look for any new rooms that have been assigned and add them to the housing_rooms table
  def regenerate
    participants = ParticipantRegistration.all

    participants.each do |participant|
      housing_room = HousingRoom.find(:first, :conditions => "building_id = '#{participant.building_id}' and number = '#{participant.room}'")
      if housing_room.nil? and !participant.building.blank? and !participant.room.blank?
        housing_room = HousingRoom.new(:building => participant.building, :number => participant.room)
        housing_room.save
      end
    end

    flash[:notice] = 'Available rooms regenerated from assigned rooms.'

    respond_to do |format|
      format.html {
        redirect_to(housing_rooms_url)
      }
    end
  end
end