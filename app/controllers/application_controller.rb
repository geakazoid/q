class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time
  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation, :credit_card_number, :security_code
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  #rescue_from ActionController::MethodNotAllowed, :with => :record_not_found
  
  # include methods in the view
  helper_method :current_page
  helper_method :admin?
  helper_method :group_leader?
  helper_method :housing_admin?
  helper_method :paperwork_admin?
  helper_method :ministry_project_admin?
  helper_method :seminar_admin?
  helper_method :equipment_admin?
  helper_method :official_admin?
  
  # define a default layout
  layout proc{ |c| c.request.xhr? ? false : 'application' }

  def current_page
    @page ||= params[:page].blank? ? 1 : params[:page].to_i
  end
  
  def admin?
    current_user && current_user.has_role?('admin')
  end

  def group_leader?
    current_user && current_user.group_leader?
  end

  def housing_admin?
    current_user && current_user.has_role?('housing_admin')
  end

  def paperwork_admin?
    current_user && current_user.has_role?('paperwork_admin')
  end

  def ministry_project_admin?
    current_user && current_user.has_role?('ministry_project_admin')
  end

  def seminar_admin?
    current_user && current_user.has_role?('seminar_admin')
  end

  def equipment_admin?
    current_user && current_user.has_role?('equipment_admin')
  end

  def official_admin?
    current_user && current_user.has_role?('official_admin')
  end
  
  # return an array of emails for admins
  def admin_emails
    emails = Array.new
    Role.find_by_name('admin').users.each do |user|
      emails << "#{user.fullname} <#{user.email}>"
    end
    emails
  end
  
  # return an array of emails for official admins
  def official_admin_emails
    emails = Array.new
    Role.find_by_name('official_admin').users.each do |user|
      emails << "#{user.fullname} <#{user.email}>"
    end
    emails
  end
  
  # return an array of emails for equipment admins
  def equipment_admin_emails
    emails = Array.new
    Role.find_by_name('equipment_admin').users.each do |user|
      emails << "#{user.fullname} <#{user.email}>"
    end
    emails
  end

  protected
  
  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
end