class SeminarRegistrationsController < ApplicationController

  before_filter :login_required, :only => :index

  # GET /seminar_registrations
  def index
    record_not_found and return if !admin? and !seminar_admin?
    @seminar_registrations = SeminarRegistration.find(:all)

    respond_to do |format|
      format.html {
        render 'seminar_registrations/admin/index'
      }
    end
  end

  # GET /seminar_registrations/new
  def new
    @seminar_registration = SeminarRegistration.new
    @districts = District.find(:all, :order => "name")

    # find our seminar page
    @page = Page.find_by_label('Seminar Registration Text')

    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # GET /seminar_registrations/schedule
  def schedule
    # find our seminar page
    @page = Page.find_by_label('Seminar Registration Text')

    respond_to do |format|
      format.html # schedule.html.erb
    end
  end

  # POST /seminar_registrations
  def create
    @seminar_registration = SeminarRegistration.new
    @seminar_registration.user = current_user
    @seminar_registration.attributes = params[:seminar_registration]

    respond_to do |format|
      if @seminar_registration.save
          flash[:notice] = 'You have successfully submitted your seminar registration.'
          format.html { redirect_to(root_url) }
      else
        @districts = District.find(:all, :order => "name")
        format.html { render :action => "new" }
      end
    end
  end
end