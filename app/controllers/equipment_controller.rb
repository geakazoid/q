class EquipmentController < ApplicationController
  require_role ['admin','equipment_admin']
  before_filter :set_cache_buster

  layout 'equipment'

  def index
    @equipment = Equipment.find(:all, :joins => [:equipment_registration], :conditions => "equipment_registrations.event_id = #{Event.active_event.id}")
    @rooms = Room.all(:order => 'name asc', :conditions => "event_id = #{Event.active_event.id}")

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def save_room
    equipment = Equipment.find(params[:id])
    equipment.room_id = params[:room_id]
    equipment.save

    render :nothing => true
  end

  def save_status
    equipment = Equipment.find(params[:id])
    equipment.status = params[:status]
    equipment.save

    render :nothing => true
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end