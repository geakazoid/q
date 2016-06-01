class TeamRegistrationsController < ApplicationController
  require 'spreadsheet'
  
  before_filter :login_required

  # GET /team_registrations
  def index
    if params[:user_id]
      @team_registrations = TeamRegistration.find(:all, :conditions => "user_id = #{params[:user_id]}")
      @user = User.find(params[:user_id])
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?
      @team_registrations = TeamRegistration.find(:all, :order => "first_name asc, last_name asc")
    end

    respond_to do |format|
      format.html {
        render "team_registrations/admin/index" if admin? and !params[:user_id]
      }
    end
  end

  # GET /team_registrations/:id
  def show
    @team_registration = TeamRegistration.find(params[:id])
  end

  # GET /team_registrations/new
  def new
    # if params[:key] != '549e474379a414690497b030be880080' and !admin?
      # @page = Page.find_by_label('Closed Team Registration Text')
      # respond_to do |format|
        # format.html {
          # render "team_registrations/closed"
        # }
      # end
      # return
    # end

    @team_registration = TeamRegistration.new
    @districts = District.find(:all, :order => "name")
    @divisions = Division.find(:all)
    @coaches = ParticipantRegistration.find(:all, :conditions => "registration_type = 'coach' OR planning_on_coaching = 'YES'")
    
    # find our first page (which should be the new team registration text)
    @page = Page.find_by_label('Register Teams Text')
    
    @team_registration.teams.build

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /team_registrations/:id/edit
  # GET /users/:user_id/team_registrations/:id/edit
  def edit
    @team_registration = TeamRegistration.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
      # if the users don't match we shouldn't be here
      record_not_found and return if @user != current_user and !admin?
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?
    end

    @districts = District.find(:all, :order => "name")
    @divisions = Division.find(:all)
    @coaches = ParticipantRegistration.find(:all, :conditions => "registration_type = 'coach' OR planning_on_coaching = 'YES'")

    respond_to do |format|
      format.html {
        render "team_registrations/admin/edit" if admin? and !params[:user_id]
      }
    end
  end

  # POST /team_registrations
  def create
    @team_registration = TeamRegistration.new
    @team_registration.user = current_user
    @team_registration.audit_user = current_user
    @team_registration.attributes = params[:team_registration]

    # update our amounts
    update_amounts

    respond_to do |format|
      if @team_registration.save
        case params[:commit_action]
        when 'registration_action'
          # mark the team_registration as paid
          @team_registration.paid = true
          @team_registration.audit_user = current_user
          @team_registration.save
          flash[:notice] = 'Team Registration submitted succesfully. It can be edited later on the team registrations page. This can be accessed by using the right sidebar.'
          format.html { redirect_to(user_team_registrations_url(current_user)) }
        when 'save_action'
          flash[:notice] = 'Team Registration saved successfully. It can be edited later on the team registrations page. This can be accessed by using the right sidebar.'
          format.html { redirect_to(root_url) }
        end
      else
        @districts = District.find(:all)
        @divisions = Division.find(:all)
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /team_registrations/:id
  # PUT /users/:user_id/team_registrations/:id
  def update
    @team_registration = TeamRegistration.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
      # if the users don't match we shouldn't be here
      record_not_found and return if @user != current_user and !admin?

      @team_registration.attributes = params[:team_registration]
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?

      if @team_registration.complete?
        @team_registration.amount = params[:team_registration]['amount']
        params[:team_registration].delete('amount')
      end
      @team_registration.attributes = params[:team_registration]
    end

    if !@team_registration.complete?
      # update amounts
      update_amounts
    end

    @team_registration.audit_user = current_user

    respond_to do |format|
      if @team_registration.save
        if !@user.nil?
          case params[:commit_action]
          when 'payment_action'
            # add team_registration to the session
            session[:team_registration] = Hash.new
            session[:team_registration][:id] = @team_registration.id
            format.html { redirect_to(new_payment_url) }
          when 'registration_action'
            # mark the team_registration as paid
            @team_registration.paid = true
            @team_registration.audit_user = current_user
            @team_registration.save
          format.html { redirect_to(confirm_team_registrations_url) }
          when 'save_action'
            flash[:notice] = 'Team Registration saved successfully. It can be edited later on the team registrations page. This can be accessed by using the right sidebar.'
            format.html { redirect_to(user_team_registrations_path(@user)) }
          when 'update_action'
            flash[:notice] = 'Team Registration updated successfully.'
            format.html { redirect_to(user_team_registrations_path(@user)) }
          end
        else
          # this is an admin update
          flash[:notice] = 'Team Registration was successfully updated.'
          format.html { redirect_to(team_registrations_path) }
        end
      else
        if !@user.nil?
          if (!@team_registration.complete?)
            @districts = District.find(:all, :order => "name")
            @divisions = Division.find(:all)
          end
          format.html { render :action => "edit" }
        else
          format.html { render "team_registrations/admin/edit" }
        end
      end
    end
  end

  # DELETE /team_registrations/:id
  def destroy
    @team_registration = TeamRegistration.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?
    end

    # destroy the team registration
    @team_registration.destroy

    flash[:notice] = 'Team Registration deleted successfully.'

    respond_to do |format|
      format.html {
        if params[:user_id]
          redirect_to(user_team_registrations_url(@user))
        else
          redirect_to(team_registrations_url)
        end
      }
    end
  end
  
  # GET /team_registration/confirm
  def confirm
    # find the page with confirmation / thank you text
    @page = Page.find_by_label('Team Confirmation Text')
    
    respond_to do |format|
      format.html
    end
  end

  private

  # update amounts
  def update_amounts
    current_registrations = 0
    current_registrations = @team_registration.district.num_district_teams unless @team_registration.district.nil?
    district_registrations = @team_registration.district_count
    discounted_count = 0
    if (current_registrations >= 2)
      discounted_count = district_registrations;
    elsif (current_registrations == 1)
      discounted_count = district_registrations - 1;
    else
      discounted_count = district_registrations - 2;
    end

    if (discounted_count < 0)
      discounted_count = 0;
    end

    # figure out total amount
    total_amount = 0
    applied_discount_count = 0
    @team_registration.teams.each do |team|
      if !team.division.nil?
        team.amount_in_cents = team.division.price_in_cents
        team.discounted = false
        # if the current user is melody sidor (id:20) she doesn't get a discount
        # this is a hack and should be removed as soon as she pays
        #if team.district_team? and applied_discount_count < discounted_count and current_user.id != 20
        #  team.discounted = true
        #  applied_discount_count += 1
        #  team.amount_in_cents -= 1500
        #end

        total_amount = total_amount + team.amount_in_cents
      end
    end
    
    @team_registration.amount_in_cents = total_amount
  end
end
