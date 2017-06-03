class EventRolesController < ApplicationController
  #require_role ['admin']

  # GET /users/:user_id/event_roles
  def index
    @new_event_role = EventRole.new

    if params[:user_id]
      @event_roles = EventRole.find(:all, :conditions => "user_id = #{params[:user_id]}")
      @user = User.find(params[:user_id])
    else
      # we weren't given a user id, so throw an error
      record_not_found and return
    end

    respond_to do |format|
      format.html
    end
  end

  # POST /users/:user_id/event_roles
  def create
    @event_role = EventRole.new
    @user = User.find(params[:user_id])
    @event_role.user = @user
    @event_role.attributes = params[:event_role]

    respond_to do |format|
      if @event_role.save
        flash[:notice] = 'Role added successfully!'
        format.html { redirect_to(user_event_roles_url(@user)) }
      else
        format.html { render :action => "index" }
      end
    end
  end

  # DELETE /users/:user_id/event_roles/:id
  def destroy
    @event_role = EventRole.find(params[:id])
    @event_role.destroy
    flash[:notice] = 'Role was successfully removed.'

    respond_to do |format|
      format.html { redirect_to(user_event_roles_url(@user)) }
    end
  end
end