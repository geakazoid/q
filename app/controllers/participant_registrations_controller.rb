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
      @participant_registrations = ParticipantRegistration.find(:all)
    end

    respond_to do |format|
      format.html {
        render "participant_registrations/admin/index" if admin? and !params[:user_id]
      }
    end
  end

  # GET /participant_registrations/new
  def new
    @participant_registration = ParticipantRegistration.new
    registerable_items = RegisterableItem.all
    registerable_items.each do |registerable_item|
      @participant_registration.registration_items.build({ :registerable_item => registerable_item })
    end
    # set default travel type
    @participant_registration.travel_type = 'unknown'
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
    @districts = District.find(:all, :order => "name")
    get_registered_teams
    get_group_leaders
    get_schools

    # find page for participant registrations text
    @page = Page.find_by_label('Register Participant Text')

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

    registerable_items = RegisterableItem.all
    registerable_items.each do |registerable_item|
      registration_item = RegistrationItem.find(:first, :conditions => "participant_registration_id = #{@participant_registration.id.to_s} and registerable_item_id = #{registerable_item.id.to_s}")
      if registration_item.nil?
        @participant_registration.registration_items.build({ :registerable_item => registerable_item })
      end
    end

    # generate list of other family registrations if we haven't paid anything yet
    if !@participant_registration.paid_any_registration_fee?
      @participant_registration.family_registrations = @participant_registration.related_family_registrations
      @family_participant_registrations = @participant_registration.family_participant_registrations
    end

    # set default payment type
    @participant_registration.payment_type = 'full'

    @districts = District.find(:all, :order => "name")
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
    @participant_registration.audit_user = current_user
    @participant_registration.attributes = params[:participant_registration]

    # create ParticipantRegistrationUser
    @participant_registration_user = ParticipantRegistrationUser.new(:user => current_user, :participant_registration => @participant_registration, :owner => true)

    # deal with extra users
    @shared_users = Array.new
    params[:extra_users].each do |id|
      user = User.find(id)
      @shared_users.push(user)
    end unless params[:extra_users].nil?

    respond_to do |format|
      if @participant_registration.save
        @participant_registration_user.save
        # save shared users
        @shared_users.each do |shared_user|
          participant_registration_user = ParticipantRegistrationUser.new(:user => shared_user, :participant_registration => @participant_registration)
          participant_registration_user.save
          ParticipantRegistrationMailer.deliver_registration_shared(current_user, shared_user)
        end
        case params[:commit]
        when "Submit Payment"
          # add participant_registration to the session
          prepare_session
          format.html { redirect_to(new_payment_url) }
        when "Submit Registration"
          # add participant_registration to the session
          prepare_session
          format.html { redirect_to(confirm_participant_registrations_url) }
        when "Save For Later"
          flash[:notice] = 'Participant Registration saved successfully. It can be edited later on the participant registrations page. This can be accessed by using the right sidebar.'
          format.html { redirect_to(root_url) }
        end
      else
        @districts = District.find(:all, :order => "name")
        @family_participant_registrations = current_user.family_participant_registrations
        get_registered_teams
        get_group_leaders
        get_schools
        # find page for participant registrations text
        @page = Page.find_by_label('Register Participant Text')
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /participant_registrations/:id
  # PUT /users/:user_id/participant_registrations/:id
  def update
    @participant_registration = ParticipantRegistration.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
      # if the users don't match we shouldn't be here
      record_not_found and return if @user != current_user and !admin?

      # hack to deal with the discount (if any)
      @participant_registration.discount = params[:participant_registration]['discount']
      params[:participant_registration].delete('discount')

      @participant_registration.attributes = params[:participant_registration]
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin?
      # hack to deal witht he discount (if any)
      @participant_registration.discount = params[:participant_registration]['discount']
      params[:participant_registration].delete('discount')

      @participant_registration.attributes = params[:participant_registration]
    end

    @participant_registration.audit_user = current_user

    # deal with extra users
    @shared_users = Array.new
    params[:extra_users].each do |id|
      user = User.find(id)
      @shared_users.push(user)
    end unless params[:extra_users].nil?

    respond_to do |format|
      if @participant_registration.save
        # saved any new shared users
        @shared_users.each do |shared_user|
          participant_registration_user = ParticipantRegistrationUser.find(:first, :conditions => "user_id = #{shared_user.id} and participant_registration_id = #{@participant_registration.id}")
          if participant_registration_user.nil?
            participant_registration_user = ParticipantRegistrationUser.new(:user => shared_user, :participant_registration => @participant_registration)
            participant_registration_user.save
            ParticipantRegistrationMailer.deliver_registration_shared(current_user, shared_user)
          end
        end
        # deleted any shared users that have been removed
        # only do this if we're the owner
        if @participant_registration.owner == current_user
          @users_to_remove = @participant_registration.shared_users - @shared_users
          @users_to_remove.each do |user|
            participant_registration_user = ParticipantRegistrationUser.find(:first, :conditions => "user_id = #{user.id} and participant_registration_id = #{@participant_registration.id}")
            participant_registration_user.destroy
          end
        end
        if !@user.nil?
          case params[:commit]
          when "Submit Payment"
            # add participant_registration to the session
            prepare_session
            format.html { redirect_to(new_payment_url) }
          when "Submit Registration"
            # add participant_registration to the session
            prepare_session
            format.html { redirect_to(confirm_participant_registrations_url) }
          when "Save For Later"
            flash[:notice] = 'Participant Registration saved successfully. It can be edited later on the participant registrations page. This can be accessed by using the right sidebar.'
            format.html { redirect_to(user_participant_registrations_path(@user)) }
          when "Update Registration"
            flash[:notice] = 'Participant Registration updated successfully.'
            format.html { redirect_to(user_participant_registrations_path(@user)) }
          end
        else
          # this is an admin update
          flash[:notice] = 'Participant Registration was successfully updated.'
          format.html { redirect_to(participant_registrations_path) }
        end
      else
        @districts = District.find(:all, :order => "name")
        # generate list of other family registrations if we haven't paid anything yet
        if !@participant_registration.paid_any_registration_fee?
          @family_participant_registrations = @participant_registration.family_participant_registrations
        end
        get_registered_teams
        get_group_leaders
        get_schools
        # find page for participant registrations text
        @page = Page.find_by_label('Register Participant Text')
        if !@user.nil?
          format.html { render :action => "edit" }
        else
          format.html { render "participant_registrations/admin/edit" }
        end
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

    # destroy the team registration
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
    
    # find the page with confirmation / thank you text
    @page = Page.find_by_label('Participant Confirmation Text')
    
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

    @participant_registrations = ParticipantRegistration.ordered_by_last_name
    @buildings = Building.all(:order => 'name')
    @districts = District.all(:order => 'name')
    @regions = Region.all(:order => 'name')

    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }.uniq
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
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
        redirect_to(housing_participant_registrations_url)
      }
    end
  end

  # GET /participant_registrations/paperwork
  def paperwork
    # if we aren't an admin or paperwork admin we shouldn't be here
    record_not_found and return if !admin? and !paperwork_admin?

    @participant_registrations = ParticipantRegistration.ordered_by_last_name
    @buildings = Building.all(:order => 'name')
    @districts = District.all(:order => 'name')
    @regions = Region.all(:order => 'name')

    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }.uniq
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
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

    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }.uniq
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
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
    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }.uniq
    @group_leaders.insert(0, ['- Select -', ''])
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
    @group_leaders.push(['My group leader is not listed.', -1])
    @group_leaders.push(['I don\'t know who my group leader is.', -2])
    @group_leaders.push(['I don\'t have a group leader.', -3])
  end

  # get all schools
  def get_schools
    @schools = School.all
  end

  # prepare our session with the correct amount to pay for
  def prepare_session
    # prepare hash for storing participant registration values
    session[:participant_registration] = Hash.new

    # find out the registration amount we're paying
    if @participant_registration.payment_type == 'partial' and @participant_registration.partial_amount.to_i * 100 <= params[:registration_amount].to_i
      registration_amount = @participant_registration.partial_amount.to_i * 100
      session[:participant_registration][:partial_payment] = true
    else
      registration_amount = params[:registration_amount].to_i
      session[:participant_registration][:partial_payment] = false
    end

    session[:participant_registration][:registration_amount] = registration_amount

    # check if we're skipping extras
    if !params[:skip_extras]
      # find out the extras amount we're paying
      extras_amount = params[:extras_amount].to_i
    else
      extras_amount = 0
    end
    
    session[:participant_registration][:extras_amount] = extras_amount

    # figure out our payment amount
    payment_amount = (registration_amount + extras_amount) / 100

    # create a details hash to store what we're paying for in the session
    details = Hash.new

    # store the registration amount
    details['registration_amount'] = registration_amount

    # store extras (unless we're skipping them)
    if !params[:skip_extras]
      # possible extra values
      boolean_extras = ['housing_sunday','housing_saturday','breakfast_monday','lunch_monday',
        'need_arrival_shuttle','need_departure_shuttle','sv_transportation']
      numeric_extras = ['num_extra_group_photos','num_dvd','num_extra_youth_small_shirts',
        'num_extra_youth_medium_shirts','num_extra_youth_large_shirts',
        'num_extra_small_shirts','num_extra_medium_shirts','num_extra_large_shirts',
        'num_extra_xlarge_shirts','num_extra_2xlarge_shirts','num_extra_3xlarge_shirts',
        'num_extra_4xlarge_shirts','num_extra_5xlarge_shirts','num_sv_tickets']

      # store any bought extras
      boolean_extras.each do |extra|
        details[extra] = eval("@participant_registration.#{extra}") if eval("@participant_registration.#{extra}?")
      end
      numeric_extras.each do |extra|
        details[extra] = eval("@participant_registration.#{extra}") if !eval("@participant_registration.#{extra}").nil? and eval("@participant_registration.#{extra}") > 0
      end
    end

    # store all values in the session
    session[:participant_registration][:id] = @participant_registration.id
    session[:participant_registration][:payment_amount] = payment_amount * 100
    session[:participant_registration][:details] = details

    # store whether we're skipping extras
    if params[:skip_extras]
      session[:participant_registration][:skip_extras] = true
    end
  end

  def clean_up
    @participant_registration = ParticipantRegistration.find(session[:participant_registration][:id])
    @participant_registration.audit_user = current_user

    # reset all extras (unless they're being skipped)
    if session[:participant_registration][:skip_extras].nil?
      numeric_extras = ['num_extra_group_photos','num_dvd','num_extra_youth_small_shirts',
        'num_extra_youth_medium_shirts','num_extra_youth_large_shirts',
        'num_extra_small_shirts','num_extra_medium_shirts','num_extra_large_shirts',
        'num_extra_xlarge_shirts','num_extra_2xlarge_shirts','num_extra_3xlarge_shirts',
        'num_extra_4xlarge_shirts','num_extra_5xlarge_shirts','num_sv_tickets']

      # reset all numeric extras to nil (this clears the form for us)
      numeric_extras.each do |extra|
        eval("@participant_registration.#{extra} = nil")
      end

      # clear out extras fee (since we just paid it)
      @participant_registration.extras_fee = 0;
    end

    # find our registration fee
    registration_fee = @participant_registration.registration_fee

    # find out what's been paid already
    registration_paid = @participant_registration.paid_registration_amount * 100

    # get our discounts (if applicable)
    registration_discount = @participant_registration.registration_discount ? @participant_registration.registration_discount : 0

    # find out what's remaining to be paid
    registration_fee_remaining = registration_fee - registration_paid - registration_discount

    if registration_fee_remaining == 0
      @participant_registration.paid = true
    end
    
    # create stub payment to deal with extras + discounts equaling 0, and core staff who don't pay for extras
    @payment = Payment.new
    @payment.user = current_user
    @payment.first_name = current_user.first_name
    @payment.last_name = current_user.last_name
    @payment.email = current_user.email
    @payment.phone = current_user.phone
    @payment.amount_in_cents = 0
    @payment.response = 'STUB TRANSACTION'
    @payment.details = session[:participant_registration][:details]
    @payment.participant_registration_id = session[:participant_registration][:id]
    @payment.save

    # save our registration back to the database
    @participant_registration.save

    # update school registration paid status if exhibitor
    if @participant_registration.exhibitor?
      @participant_registration.school.paid = true
      @participant_registration.school.save
    end
  end
  
  # claim a participant registration using a confirmation code
  def claim
    if request.post?
      participant_registration = ParticipantRegistration.find_by_confirmation_number(params[:confirmation_number])
      unless participant_registration.nil?
        participant_registration_user = ParticipantRegistrationUser.find(:first, :conditions => "user_id = #{current_user.id} and participant_registration_id = #{participant_registration.id}")
        if participant_registration_user.nil?
          participant_registration_user = ParticipantRegistrationUser.new
          participant_registration_user.user = current_user
          participant_registration_user.participant_registration = participant_registration
          participant_registration_user.owner = true
          participant_registration_user.save
          claim_message = "Registration #{params[:confirmation_number]} (#{participant_registration.full_name}) claimed successfully!"
        else
          claim_message = "Registration #{params[:confirmation_number]} (#{participant_registration.full_name}) has already been claimed."
        end
      end
      flash.now[:notice] = claim_message
    end
  end
end