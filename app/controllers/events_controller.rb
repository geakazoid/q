class EventsController < ApplicationController
  require_role 'admin'

  # GET /events
  def index
    @events = Event.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /events/new
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /events
  def create
    @event = Event.new
    @event.attributes = params[:event]

    respond_to do |format|
      if @event.save
        update_status_for_all_events
        flash[:notice] = 'You have successfully created your event.'
        format.html { redirect_to(events_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # PUT /events/:id
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        update_status_for_all_events
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(events_url) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  # DELETE /events/:id
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    
    flash[:notice] = 'Event deleted successfully.'

    respond_to do |format|
      format.html { redirect_to(events_url) }
    end
  end

  def update_status_for_all_events
    if @event.active?
      Event.connection.execute("UPDATE events SET active = false WHERE id != " + @event.id.to_s)
    end
  end
end
