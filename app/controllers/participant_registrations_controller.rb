class ParticipantRegistrationsController < ApplicationController
  require "spreadsheet"

  before_filter :login_required

  # GET /participant_registrations
  # GET /users/:user_id/participant_registrations
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?

      @selected_event = params[:event_id] ? params[:event_id] : Event.active_event.id
      @events = Event.get_events
      #@participant_registrations = ParticipantRegistration.find(:all, :conditions => "event_id = #{@selected_event}", :order => "first_name asc, last_name asc")
      @participant_registrations = ParticipantRegistration.by_event(Event.active_event.id).ordered_by_last_name
      @districts = District.all(:order => 'name')
      @regions = Region.all(:order => 'name')
      get_group_leaders

      # filter results if we have any filters
      unless session[:paid].blank?
        if (session[:paid] == '1')
          @participant_registrations = @participant_registrations.complete
          @filter_applied = true
        elsif (session[:paid] == '0')
          @participant_registrations = @participant_registrations.incomplete
          @filter_applied = true
        end
      end
      unless session[:group_leader_assignment].blank?
        if (session[:group_leader_assignment] == 'defined')
          @participant_registrations = @participant_registrations.group_leader_defined
          @filter_applied = true
        elsif (session[:group_leader_assignment] == 'undefined')
          @participant_registrations = @participant_registrations.group_leader_undefined
          @filter_applied = true
        end
      end
      unless session[:group_leader].blank?
        @participant_registrations = @participant_registrations.by_group_leader(session[:group_leader])
        @filter_applied = true
      end
      unless session[:district_id].blank?
        @participant_registrations = @participant_registrations.by_district(session[:district_id])
        @filter_applied = true
      end
      unless session[:region_id].blank?
        @participant_registrations = @participant_registrations.by_region(session[:region_id])
        @filter_applied = true
      end
    end

    respond_to do |format|
      format.html {
        render "participant_registrations/admin/index" if admin? and !params[:user_id]
      }
    end
  end

  # GET /participant_registrations/filter/?parameters
  # filter list based upon passed in filters
  def filter
    # if we aren't an admin or housing admin we shouldn't be here
    record_not_found and return if !admin?

    # clear filters if requested
    if params[:clear] == 'true'
      session[:paid] = nil
      session[:group_leader_assignment] = nil
      session[:group_leader] = nil
      session[:district_id] = nil
      session[:region_id] = nil
 
      flash[:notice] = 'All filters have been cleared.'
    else
      # update session values from passed in params
      session[:paid] = params[:paid] unless params[:paid].blank?
      session[:group_leader_assignment] = params[:group_leader_assignment] unless params[:group_leader_assignment].blank?
      session[:group_leader] = params[:group_leader] unless params[:group_leader].blank?
      session[:district_id] = params[:district_id] unless params[:district_id].blank?
      session[:region_id] = params[:region_id] unless params[:region_id].blank?

      # remove filters if none is passed
      session[:paid] = nil if params[:paid] == 'none'
      session[:group_leader_assignment] = nil if params[:group_leader_assignment] == 'none'
      session[:group_leader] = nil if params[:group_leader] == 'none'
      session[:district_id] = nil if params[:district_id] == 'none'
      session[:region_id] = nil if params[:region_id] == 'none'
    
      flash[:notice] = 'Filters updated successfully.'
    end

    respond_to do |format|
      format.html {
        redirect_to(participant_registrations_url)
      }
    end
  end

  # GET /participant_registrations/new
  def new
    # if registration is closed and we don't have a code we redirect
    if !Event.active_event.enable_participant_registration? and params[:code] != Event.active_event.participant_code
      respond_to do |format|
        format.html { redirect_to(root_url) }
      end
      return
    end

    @participant_registration = ParticipantRegistration.new
    registerable_items = RegisterableItem.all
    registerable_items.each do |registerable_item|
      @participant_registration.registration_items.build({ :registerable_item => registerable_item })
    end
    # set default housing and meals for participants
    @participant_registration.participant_housing = 'meals_and_housing'
    # set default housing and meals for exhibitors
    @participant_registration.exhibitor_housing = 'on_campus'
    # set default payment type
    @participant_registration.payment_type = 'full'
    # generate list of other family registrations
    @participant_registration.family_registrations = current_user.list_family_registrations
    @family_participant_registrations = current_user.family_participant_registrations
    @shared_users = Array.new
    @districts = District.find(:all, :order => 'name')
    @registration_options_meals = RegistrationOption.all(:conditions => 'category = "meal" and event_id = ' + Event.active_id.to_s, :order => 'sort')
    @registration_options_other = RegistrationOption.all(:conditions => 'category = "other" and event_id = ' + Event.active_id.to_s, :order => 'sort')
    get_registered_teams
    get_group_leaders
    get_schools

    # find page for participant registrations text
    @page = Page.find_by_label('Register Participant Text')

    # define if user can pay with a check
    if params[:code] == 'gh56q13'
      @pay_by_check = true
    end

    respond_to do |format|
      format.html
    end
  end

  # GET /participant_registrations/:id/edit
  # GET /users/:user_id/participant_registrations/:id/edit
  def edit
    @participant_registration = ParticipantRegistration.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
      # if the users don't match we shouldn't be here
      record_not_found and return if @user != current_user and !admin?
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?
    end

    # define shared users (if any)
    @shared_users = @participant_registration.shared_users

    # set default payment type
    @participant_registration.payment_type = 'full'

    @districts = District.find(:all, :order => 'name')
    @registration_options_meals = RegistrationOption.all(:conditions => 'category = "meal" and event_id = ' + Event.active_id.to_s, :order => 'sort')
    @registration_options_other = RegistrationOption.all(:conditions => 'category = "other" and event_id = ' + Event.active_id.to_s, :order => 'sort')
    get_registered_teams
    get_group_leaders
    get_schools

    # find page for participant registrations text
    @page = Page.find_by_label('Register Participant Text')

    respond_to do |format|
      format.html {
        render "participant_registrations/admin/edit" if admin? and !params[:user_id]
      }
    end
  end

  # POST /participant_registrations
  def create
    @participant_registration = ParticipantRegistration.new
    @participant_registration.amount_ordered = params[:registration_fee].to_i
    @participant_registration.audit_user = current_user
    @participant_registration.attributes = params[:participant_registration]
    @participant_registration.event = Event.active_event

    # create ParticipantRegistrationUser
    @participant_registration_user = ParticipantRegistrationUser.new(:user => current_user, :participant_registration => @participant_registration, :owner => true)

    respond_to do |format|
      if @participant_registration.save
        @participant_registration_user.save
        #flash[:notice] = "Participant registered successfully! You can see the participants you've registered on your registrations page. This can be accessed by using the right sidebar."
        # add participant_registration to the session
        prepare_session
        registration_fee = @participant_registration.amount_ordered * 100
        if (params[:pay_by_check] == "true")
          # no need to ask for payment, send to confirmation check page
          format.html { redirect_to(confirm_check_participant_registrations_url) }
        else
          # send to transactions controller
          format.html { redirect_to(AppConfig.site_url + '/transactions/new') }
        end
      else
        @districts = District.find(:all, :order => "name")
        @registration_options_meals = RegistrationOption.all(:conditions => 'category = "meal" and event_id = ' + Event.active_id.to_s, :order => 'sort')
        @registration_options_other = RegistrationOption.all(:conditions => 'category = "other" and event_id = ' + Event.active_id.to_s, :order => 'sort')
        @family_participant_registrations = current_user.family_participant_registrations
        get_registered_teams
        get_group_leaders
        get_schools
        # find page for participant registrations text
        @page = Page.find_by_label('Register Participant Text')
        # define if user can pay with a check
        if params[:pay_by_check] == 'true'
          @pay_by_check = true
        end
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /participant_registrations/:id
  # PUT /users/:user_id/participant_registrations/:id
  def update
    @participant_registration = ParticipantRegistration.find(params[:id])
    # if we aren't an admin we shouldn't be here
    record_not_found and return if !admin?

    @participant_registration.attributes = params[:participant_registration]

    @participant_registration.audit_user = current_user

    respond_to do |format|
      validate = false
      if @participant_registration.save(validate)
        # deleted any shared users that have been removed
        # only do this if we're the owner
      
        # this is an admin update
        flash[:notice] = 'Participant Registration was successfully updated.'
        format.html { redirect_to(participant_registrations_path) }
      else
        @districts = District.find(:all, :order => "name")
        @registration_options_meals = RegistrationOption.all(:conditions => 'category = "meal"', :order => 'sort')
        @registration_options_other = RegistrationOption.all(:conditions => 'category = "other"', :order => 'sort')
        get_registered_teams
        get_group_leaders
        get_schools
        # find page for participant registrations text
        @page = Page.find_by_label('Register Participant Text')
        format.html { render "participant_registrations/admin/edit" }
      end
    end
  end

  # DELETE /participant_registrations/:id
  # DELETE /users/:user_id/participant_registrations/:id
  def destroy
    @participant_registration = ParticipantRegistration.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?
    end

    # destroy the participant registration
    @participant_registration.destroy

    flash[:notice] = 'Participant Registration deleted successfully.'

    respond_to do |format|
      format.html {
        if params[:user_id]
          redirect_to(user_participant_registrations_url(@user))
        else
          redirect_to(participant_registrations_url)
        end
      }
    end
  end
  
  # GET /participant_registration/confirm
  def confirm
    # clean up the session and save our registration
    clean_up
    
    respond_to do |format|
      format.html
    end
  end

  # GET /participant_registration/confirm_check
  def confirm_check
    @participant_registration = ParticipantRegistration.find(session[:participant_registration][:id])
    
    respond_to do |format|
      format.html
    end
  end

  # GET /participant_registration/convio
  # placeholder for 3rd party credit card site
  def convio
    respond_to do |format|
      format.html
    end
  end

  # GET /participant_registration/add_shared_user?email=:email&shared_users=:id,:id
  def add_shared_user
    user = User.find_by_email(params[:email])

    if !user.nil? and user != current_user
      html =  "<span id='extra_user_#{user.id}'>"
      html << "<input type='hidden' name='extra_users[]' value='#{user.id}'>#{user.fullname} (#{user.email}) "
      html << @template.link_to_remote('Remove', {:url => remove_shared_user_participant_registrations_url, :method => :get, :with => "'id=#{user.id}&shared_users=' + $('shared_users').value"})
      html << "<br/></span>"
      shared_users = params[:shared_users].split(',')
      if shared_users.include?(user.id.to_s)
        already_shared = true
      else
        shared_users.push(user.id)
      end
    end

    render :update do |page|
      if params[:email].blank?
        display_sharing_error(page, 'Please enter an email address.')
      elsif user.nil?
        display_sharing_error(page, 'User with that email address was not found!')
      elsif user == current_user
        display_sharing_error(page, 'You cannot share this registration with yourself!')
      elsif already_shared
        display_sharing_error(page, 'You are already sharing with this user!')
      else
        display_sharing_info(page, "This registration will be shared with #{user.fullname}.")
        page.show 'extra_users_title'
        page.insert_html :bottom, 'extra_users', html
        page['email_search'].value = ''
        page['shared_users'].value = shared_users.join(',')
      end
    end
  end

  # GET /participant_registration/remove_shared_user?id=:id&shared_users=:id,:id
  def remove_shared_user
    user = User.find(params[:id])

    # update shared users
    shared_users = params[:shared_users].split(',')
    shared_users.delete(user.id.to_s)

    render :update do |page|
      if params[:id].blank? or user.nil?
        display_sharing_error(page, 'An error occurred.')
      else
        display_sharing_info(page, "This registration will no longer be shared with #{user.fullname}.")
        page.remove "extra_user_#{user.id}"
        page['email_search'].value = ''
        page['shared_users'].value = shared_users.join(',')
      end
    end
  end

  def audit
    record_not_found unless admin?

    @participant_registration = ParticipantRegistration.find(params[:id])
    respond_to do |format|
      format.html {
        render "participant_registrations/admin/audit"
      }
    end
  end

  # GET /participant_registrations/housing
  def housing
    # if we aren't an admin or housing admin we shouldn't be here
    record_not_found and return if !admin? and !housing_admin?

    @participant_registrations = ParticipantRegistration.by_event(Event.active_event.id).needs_housing.ordered_by_last_name
    @buildings = Building.all(:conditions => "event_id = #{Event.active_event.id}", :order => 'name')
    @districts = District.all(:order => 'name')
    @regions = Region.all(:order => 'name')

    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "event_id = #{Event.active_event.id}", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    @group_leaders = @group_leaders.uniq.sort_by { |user| user[0].downcase }
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
    @group_leaders.push(['Representative', -7])
    @group_leaders.push(['Group Leader Not Listed', -1])
    @group_leaders.push(['Group Leader Not Known', -2])
    @group_leaders.push(['No Group Leader', -3])

    # filter results if we have any filters
    unless params[:q].blank?
      @participant_registrations = @participant_registrations.search(params[:q])
      @filter_applied = true
    end
    unless session[:registration_type].blank?
      @participant_registrations = @participant_registrations.by_registration_type(session[:registration_type])
      @filter_applied = true
    end
    unless session[:status].blank?
      if (session[:status] == 'complete')
        @participant_registrations = @participant_registrations.housing_complete
        @filter_applied = true
      elsif (session[:status] == 'incomplete')
        @participant_registrations = @participant_registrations.housing_incomplete
        @filter_applied = true
      end
    end
    unless session[:district_id].blank?
      @participant_registrations = @participant_registrations.by_district(session[:district_id])
      @filter_applied = true
    end
    unless session[:region_id].blank?
      @participant_registrations = @participant_registrations.by_region(session[:region_id])
      @filter_applied = true
    end
    unless session[:building_id].blank?
      @participant_registrations = @participant_registrations.by_building(session[:building_id])
      @filter_applied = true
    end
    unless session[:group_leader].blank?
      @participant_registrations = @participant_registrations.by_group_leader(session[:group_leader])
      @filter_applied = true
    end
    unless session[:gender].blank?
      @participant_registrations = @participant_registrations.by_gender(session[:gender])
      @filter_applied = true
    end

    # filter out anyone that got a housing discount
    @temp_participant_registrations = Array.new
    offcampus_discount = RegistrationOption.find_by_item('Off-Campus Housing Discount')
    @participant_registrations.each do |registration|
      if (!registration.registration_options.include?(offcampus_discount))
        @temp_participant_registrations.push(registration)
      end
    end
    @participant_registrations = @temp_participant_registrations
    
    respond_to do |format|
      format.html {
        render "participant_registrations/admin/housing"
      }
    end
  end

  # POST /participant_registrations/save_housing
  # save values off of housing form
  def save_housing
    # if we aren't an admin or housing admin we shouldn't be here
    record_not_found and return if !admin? and !housing_admin?

    params['participant_registration'].each do |id,data|
      pr = ParticipantRegistration.find(id)
      pr.room = data['room']
      pr.building_id = data['building_id']
      pr.save(false)
    end

    flash[:notice] = 'Housing Information saved successfully.'

    respond_to do |format|
      format.html {
        redirect_to(housing_participant_registrations_url)
      }
    end
  end

  # GET /participant_registrations/filter_housing/?parameters
  # filter housing list based upon passed in filters
  def filter_housing
    # if we aren't an admin or housing admin we shouldn't be here
    record_not_found and return if !admin? and !housing_admin?

    # clear filters if requested
    if params[:clear] == 'true'
      session[:registration_type] = nil
      session[:status] = nil
      session[:district_id] = nil
      session[:region_id] = nil
      session[:building_id] = nil
      session[:group_leader] = nil
      session[:gender] = nil
 
      flash[:notice] = 'All filters have been cleared.'
    else
      # update session values from passed in params
      session[:registration_type] = params[:registration_type] unless params[:registration_type].blank?
      session[:status] = params[:status] unless params[:status].blank?
      session[:district_id] = params[:district_id] unless params[:district_id].blank?
      session[:region_id] = params[:region_id] unless params[:region_id].blank?
      session[:building_id] = params[:building_id] unless params[:building_id].blank?
      session[:group_leader] = params[:group_leader] unless params[:group_leader].blank?
      session[:gender] = params[:gender] unless params[:gender].blank?

      # remove filters if none is passed
      session[:registration_type] = nil if params[:registration_type] == 'none'
      session[:status] = nil if params[:status] == 'none'
      session[:district_id] = nil if params[:district_id] == 'none'
      session[:region_id] = nil if params[:region_id] == 'none'
      session[:building_id] = nil if params[:building_id] == 'none'
      session[:group_leader] = nil if params[:group_leader] == 'none'
      session[:gender] = nil if params[:gender] == 'none'
    
      flash[:notice] = 'Filters updated successfully.'
    end

    respond_to do |format|
      format.html {
        redirect_to(housing_participant_registrations_url)
      }
    end
  end

  # GET /participant_registrations/paperwork
  def paperwork
    # if we aren't an admin or paperwork admin we shouldn't be here
    record_not_found and return if !admin? and !paperwork_admin?

    @participant_registrations = ParticipantRegistration.by_event(Event.active_event.id).ordered_by_last_name
    @buildings = Building.all(:order => 'name')
    @districts = District.all(:order => 'name')
    @regions = Region.all(:order => 'name')

    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "event_id = #{Event.active_event.id}", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    @group_leaders = @group_leaders.uniq.sort_by { |user| user[0].downcase }
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
    @group_leaders.push(['Representative', -7])
    @group_leaders.push(['Group Leader Not Listed', -1])
    @group_leaders.push(['Group Leader Not Known', -2])
    @group_leaders.push(['No Group Leader', -3])

    # filter results if we have any filters
    unless params[:q].blank?
      @participant_registrations = @participant_registrations.search(params[:q])
      @filter_applied = true
    end
    unless session[:registration_type].blank?
      @participant_registrations = @participant_registrations.by_registration_type(session[:registration_type])
      @filter_applied = true
    end
    unless session[:status].blank?
      if (session[:status] == 'medical_liability_complete')
        @participant_registrations = @participant_registrations.medical_liability_complete
        @filter_applied = true
      elsif (session[:status] == 'medical_liability_incomplete')
        @participant_registrations = @participant_registrations.medical_liability_incomplete
        @filter_applied = true
      elsif (session[:status] == 'background_check_complete')
        @participant_registrations = @participant_registrations.background_check_complete
        @filter_applied = true
      elsif (session[:status] == 'background_check_incomplete')
        @participant_registrations = @participant_registrations.background_check_incomplete
        @filter_applied = true
      elsif (session[:status] == 'nazsafe_complete')
        @participant_registrations = @participant_registrations.nazsafe_complete
        @filter_applied = true
      elsif (session[:status] == 'nazsafe_incomplete')
        @participant_registrations = @participant_registrations.nazsafe_incomplete
        @filter_applied = true
      end
    end
    unless session[:district_id].blank?
      @participant_registrations = @participant_registrations.by_district(session[:district_id])
      @filter_applied = true
    end
    unless session[:region_id].blank?
      @participant_registrations = @participant_registrations.by_region(session[:region_id])
      @filter_applied = true
    end
    unless session[:group_leader].blank?
      @participant_registrations = @participant_registrations.by_group_leader(session[:group_leader])
      @filter_applied = true
    end

    respond_to do |format|
      format.html {
        render "participant_registrations/admin/paperwork"
      }
    end
  end

  # POST /participant_registrations/save_paperwork
  # save values off of paperwork form
  def save_paperwork
    # if we aren't an admin or paperwork admin we shouldn't be here
    record_not_found and return if !admin? and !paperwork_admin?

    params['participant_registration'].each do |id,data|
      pr = ParticipantRegistration.find(id)
      pr.medical_liability = data['medical_liability']
      pr.background_check = data['background_check']
      pr.nazsafe = data['nazsafe']
      pr.save
    end

    flash[:notice] = 'Paperwork Information saved successfully.'

    respond_to do |format|
      format.html {
        redirect_to(paperwork_participant_registrations_url)
      }
    end
  end

  # GET /participant_registrations/filter_paperwork/?parameters
  # filter paperwork list based upon passed in filters
  def filter_paperwork
    # if we aren't an admin or paperwork admin we shouldn't be here
    record_not_found and return if !admin? and !paperwork_admin?

    # clear filters if requested
    if params[:clear] == 'true'
      session[:registration_type] = nil
      session[:status] = nil
      session[:district_id] = nil
      session[:region_id] = nil
      session[:building_id] = nil
      session[:group_leader] = nil

      flash[:notice] = 'All filters have been cleared.'
    else
      # update session values from passed in params
      session[:registration_type] = params[:registration_type] unless params[:registration_type].blank?
      session[:status] = params[:status] unless params[:status].blank?
      session[:district_id] = params[:district_id] unless params[:district_id].blank?
      session[:region_id] = params[:region_id] unless params[:region_id].blank?
      session[:building_id] = params[:building_id] unless params[:building_id].blank?
      session[:group_leader] = params[:group_leader] unless params[:group_leader].blank?

      # remove filters if none is passed
      session[:registration_type] = nil if params[:registration_type] == 'none'
      session[:status] = nil if params[:status] == 'none'
      session[:district_id] = nil if params[:district_id] == 'none'
      session[:region_id] = nil if params[:region_id] == 'none'
      session[:building_id] = nil if params[:building_id] == 'none'
      session[:group_leader] = nil if params[:group_leader] == 'none'

      flash[:notice] = 'Filters updated successfully.'
    end

    respond_to do |format|
      format.html {
        redirect_to(paperwork_participant_registrations_url)
      }
    end
  end

  # GET /participant_registrations/ministry_project
  def ministry_project
    # if we aren't an admin or ministry project admin we shouldn't be here
    record_not_found and return if !admin? and !ministry_project_admin?

    @participant_registrations = ParticipantRegistration.ordered_by_last_name
    @buildings = Building.all(:order => 'name')
    @districts = District.all(:order => 'name')
    @regions = Region.all(:order => 'name')
    @divisions = Division.all(:order => 'name')
    @ministry_projects = MinistryProject.all(:conditions => 'name != "Not Participating"', :order => 'name')
    # add in Not Participating onto the top - HACK!! (scandalous)
    not_participating = MinistryProject.find_by_name('Not Participating')
    @ministry_projects.unshift(not_participating) unless not_participating.nil?

    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "event_id = #{Event.active_event.id}", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    @group_leaders = @group_leaders.uniq.sort_by { |user| user[0].downcase }
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
    @group_leaders.push(['Representative', -7])
    @group_leaders.push(['Group Leader Not Listed', -1])
    @group_leaders.push(['Group Leader Not Known', -2])
    @group_leaders.push(['No Group Leader', -3])

    # filter results if we have any filters
    unless params[:q].blank?
      @participant_registrations = @participant_registrations.search(params[:q])
      @filter_applied = true
    end
    unless session[:registration_type].blank?
      @participant_registrations = @participant_registrations.by_registration_type(session[:registration_type])
      @filter_applied = true
    end
    unless session[:status].blank?
      if (session[:status] == 'complete_with_group')
        @participant_registrations = @participant_registrations.ministry_project_complete_with_group
        @filter_applied = true
      elsif (session[:status] == 'complete')
        @participant_registrations = @participant_registrations.ministry_project_complete
        @filter_applied = true
      elsif (session[:status] == 'incomplete')
        @participant_registrations = @participant_registrations.ministry_project_incomplete
        @filter_applied = true
      end
    end
    unless session[:district_id].blank?
      @participant_registrations = @participant_registrations.by_district(session[:district_id])
      @filter_applied = true
    end
    unless session[:region_id].blank?
      @participant_registrations = @participant_registrations.by_region(session[:region_id])
      @filter_applied = true
    end
    unless session[:building_id].blank?
      @participant_registrations = @participant_registrations.by_building(session[:building_id])
      @filter_applied = true
    end
    unless session[:ministry_project_id].blank?
      @participant_registrations = @participant_registrations.by_ministry_project(session[:ministry_project_id])
      @filter_applied = true
    end
    unless session[:group_leader].blank?
      @participant_registrations = @participant_registrations.by_group_leader(session[:group_leader])
      @filter_applied = true
    end
    unless session[:grade].blank?
      @participant_registrations = @participant_registrations.by_grade(session[:grade])
      @filter_applied = true
    end
    unless session[:division_id].blank?
      @participant_registrations = @participant_registrations.by_division(session[:division_id])
      @filter_applied = true
    end

    respond_to do |format|
      format.html {
        render "participant_registrations/admin/ministry_project"
      }
    end
  end

  # POST /participant_registrations/save_ministry_project
  # save values off of ministry project form
  def save_ministry_project
    # if we aren't an admin or ministry project admin we shouldn't be here
    record_not_found and return if !admin? and !ministry_project_admin?

    params['participant_registration'].each do |id,data|
      pr = ParticipantRegistration.find(id)
      pr.ministry_project_group = data['ministry_project_group']
      pr.ministry_project_id = data['ministry_project_id']
      not_participating = MinistryProject.find_by_name('Not Participating')
      if pr.ministry_project == not_participating
        pr.ministry_project_group = 'none'
      end
      pr.save
    end

    flash[:notice] = 'Ministry project information saved successfully.'

    respond_to do |format|
      format.html {
        redirect_to(ministry_project_participant_registrations_url)
      }
    end
  end

  # GET /participant_registrations/filter_ministry_project/?parameters
  # filter ministry project list based upon passed in filters
  def filter_ministry_project
    # if we aren't an admin or ministry project admin we shouldn't be here
    record_not_found and return if !admin? and !ministry_project_admin?

    # clear filters if requested
    if params[:clear] == 'true'
      session[:registration_type] = nil
      session[:status] = nil
      session[:district_id] = nil
      session[:region_id] = nil
      session[:building_id] = nil
      session[:ministry_project_id] = nil
      session[:group_leader] = nil
      session[:grade] = nil
      session[:division_id] = nil

      flash[:notice] = 'All filters have been cleared.'
    else
      # update session values from passed in params
      session[:registration_type] = params[:registration_type] unless params[:registration_type].blank?
      session[:status] = params[:status] unless params[:status].blank?
      session[:district_id] = params[:district_id] unless params[:district_id].blank?
      session[:region_id] = params[:region_id] unless params[:region_id].blank?
      session[:building_id] = params[:building_id] unless params[:building_id].blank?
      session[:ministry_project_id] = params[:ministry_project_id] unless params[:ministry_project_id].blank?
      session[:group_leader] = params[:group_leader] unless params[:group_leader].blank?
      session[:grade] = params[:grade] unless params[:grade].blank?
      session[:division_id] = params[:division_id] unless params[:division_id].blank?

      # remove filters if none is passed
      session[:registration_type] = nil if params[:registration_type] == 'none'
      session[:status] = nil if params[:status] == 'none'
      session[:district_id] = nil if params[:district_id] == 'none'
      session[:region_id] = nil if params[:region_id] == 'none'
      session[:building_id] = nil if params[:building_id] == 'none'
      session[:ministry_project_id] = nil if params[:ministry_project_id] == 'none'
      session[:group_leader] = nil if params[:group_leader] == 'none'
      session[:grade] = nil if params[:grade] == 'none'
      session[:division_id] = nil if params[:division_id] == 'none'

      flash[:notice] = 'Filters updated successfully.'
    end

    respond_to do |format|
      format.html {
        redirect_to(ministry_project_participant_registrations_url)
      }
    end
  end

  # get all registered teams (teams which have been paid for)
  def get_registered_teams
    @teams = Team.find(:all, :joins => [:division, :team_registration], :order => "divisions.name,teams.name", :conditions => "team_registrations.paid = true")
  end

  # get all group leaders (someone who's registered a team)
  def get_group_leaders
    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "event_id = #{Event.active_event.id}", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    @group_leaders = @group_leaders.uniq.sort_by { |user| user[0].downcase }
    @group_leaders.insert(0, ['- Select -', ''])
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
    @group_leaders.push(['Representative', -7])
    @group_leaders.push(['My group leader is not listed.', -1])
    @group_leaders.push(['I don\'t know who my group leader is.', -2])
    @group_leaders.push(['I don\'t have a group leader.', -3])
    logger.info(@group_leaders.inspect)
  end

  # get all schools
  def get_schools
    @schools = School.all
  end

  # prepare our session with the correct amount to pay for
  def prepare_session
    # prepare hash for storing participant registration values
    session[:participant_registration] = Hash.new

    # store all values in the session
    session[:participant_registration][:id] = @participant_registration.id
  end

  def clean_up
    @participant_registration = ParticipantRegistration.find(session[:participant_registration][:id])
    @participant_registration.audit_user = current_user
    @participant_registration.paid = true

    # save our registration back to the database
    @participant_registration.save

    # clean up the session
    session[:participant_registration] = nil
  end
  
  # claim a participant registration using a confirmation code
  def claim
    if request.post?
      participant_registration = ParticipantRegistration.find_by_confirmation_number(params[:confirmation_number])
      unless participant_registration.nil?
        # check to see if it's already been claimed by someone else
        owners = ParticipantRegistrationUser.find(:all, :conditions => "participant_registration_id = #{participant_registration.id} and owner = 1")
        if owners.count == 1
          claim_message = "Registration #{params[:confirmation_number]} (#{participant_registration.full_name}) has already been claimed."
        else

          participant_registration_user = ParticipantRegistrationUser.find(:first, :conditions => "user_id = #{current_user.id} and participant_registration_id = #{participant_registration.id}")
          if participant_registration_user.nil?
            participant_registration_user = ParticipantRegistrationUser.new
            participant_registration_user.user = current_user
            participant_registration_user.participant_registration = participant_registration
            participant_registration_user.owner = true
            participant_registration_user.save
            claim_message = "Registration #{params[:confirmation_number]} (#{participant_registration.full_name}) claimed successfully!"
          end
        end
      end
      flash.now[:notice] = claim_message
    end
  end

  # attempt to autoselect group leader for registrations based on
  # supplied email and name from the registration
  def match_group_leaders
    # keep counts
    processed = 0
    skipped = 0
    matched = 0
    not_matched = 0

    participant_registrations = ParticipantRegistration.find(:all, :conditions => "event_id = #{params['event_id']}", :order => "first_name asc, last_name asc")
    participant_registrations.each do |participant_registration|
      processed += 1
      if !participant_registration.group_leader.nil? and !participant_registration.group_leader.blank?
        skipped += 1
        next
      end
      # check by user type (officials get official group leader, staff gets staff group leader)
      if (participant_registration.registration_type == 'official')
        participant_registration.group_leader = -5
        # don't validate before save
        participant_registration.save(false)
        matched += 1
        next
      end
      if (participant_registration.registration_type == 'staff')
        participant_registration.group_leader = -4
        # don't validate before save
        participant_registration.save(false)
        matched += 1
        next
      end
      # check by group leader email
      group_leader = User.find(:first, :conditions => "event_id = #{Event.active_event.id} and email = '#{participant_registration.group_leader_email}'") unless participant_registration.group_leader_email.blank? rescue nil
      if (!group_leader.nil?)
        participant_registration.group_leader = group_leader.id
        # don't validate before save
        participant_registration.save(false)
        matched += 1
        next
      end
      # check by group leader name (in group_leader_text field)
      if !participant_registration.group_leader_text.nil? and !participant_registration.group_leader_text.blank?
        first_name,last_name = participant_registration.group_leader_text.split(' ')
        group_leader = User.find(:first, :joins => [:team_registrations], :conditions => "event_id = #{Event.active_event.id} and users.first_name = '#{first_name}' and users.last_name = '#{last_name}'") rescue nil
        if (!group_leader.nil?)
          participant_registration.group_leader = group_leader.id
          # don't validate before save
          participant_registration.save(false)
          matched += 1
          next
        end
      end
      not_matched += 1
    end

    flash[:notice] = "Updated Group Leaders. Processed #{processed} registrations. #{skipped} registrations were skipped because they already have a group leader defined. #{matched} registrations were matched and updated. #{not_matched} registrations could not be matched and have not been modified."

    respond_to do |format|
      format.html {
        redirect_to(participant_registrations_url)
      }
    end

  end

  # correct group leaders that were linked incorrectly (not a group leader for the current event)
  def fix_group_leaders
    get_group_leaders

    # keep counts
    processed = 0
    skipped = 0
    matched = 0
    not_matched = 0

    participant_registrations = ParticipantRegistration.find(:all, :conditions => "event_id = #{params['event_id']}", :order => "first_name asc, last_name asc")
    participant_registrations.each do |participant_registration|
      processed += 1
      if participant_registration.group_leader.nil? or participant_registration.group_leader.blank?
        skipped += 1
        next
      end

      # check by user type and skip if foound
      if (participant_registration.registration_type == 'official')
        skipped += 1
        next
      end
      if (participant_registration.registration_type == 'staff')
        skipped += 1
        next
      end

      if (!participant_registration.group_leader.nil?)
        found = false
        @group_leaders.each do |group_leader, id|
          if (id.to_s == participant_registration.group_leader.to_s)
            found = true
            logger.info("FOUND")
          end
        end

        if (!found)
          participant_registration.group_leader = ''
          participant_registration.save(false)
          matched += 1
          next
        end
      end

      not_matched += 1
    end

    flash[:notice] = "Fixed Group Leaders. Processed #{processed} registrations. #{skipped} registrations were skipped because they already have a correct group leader defined. #{matched} registrations were updated to no group leader. #{not_matched} registrations could not be matched and have not been modified."

    logger.info(@group_leaders)
    respond_to do |format|
      format.html {
        redirect_to(participant_registrations_url)
      }
    end

  end
end
