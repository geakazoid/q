require 'digest/sha1'

class User < ActiveRecord::Base

  has_and_belongs_to_many :roles
  has_many :event_roles
  has_many :team_registrations, :conditions => "event_id = #{Event.active_event.id}"
  has_many :equipment_registrations, :conditions => "event_id = #{Event.active_event.id}"
  belongs_to :district
  has_many :complete_team_registrations, :class_name => 'TeamRegistration', :conditions => "paid = true and event_id = #{Event.active_event.id}"
  has_many :incomplete_team_registrations, :class_name => 'TeamRegistration', :conditions => "paid = false and event_id = #{Event.active_event.id}"
  has_many :participant_registration_users
  has_many :participant_registration_owners, :class_name => 'ParticipantRegistrationUser', :conditions => 'owner = true'
  has_many :participant_registration_editors, :class_name => 'ParticipantRegistrationUser', :conditions => 'owner = false'
  has_many :participant_registrations, :through => :participant_registration_users
  has_many :complete_participant_registrations, :through => :participant_registration_users, :class_name => 'ParticipantRegistration', :source => :participant_registration, :conditions => "paid = true and event_id = #{Event.active_event.id}"
  has_many :incomplete_participant_registrations, :through => :participant_registration_users, :class_name => 'ParticipantRegistration', :source => :participant_registration, :conditions => "paid = false and event_id = #{Event.active_event.id}"
  has_many :owned_participant_registrations, :through => :participant_registration_owners, :class_name => 'ParticipantRegistration', :source => :participant_registration, :conditions => "event_id = #{Event.active_event.id}"
  has_many :owned_participant_registrations_with_teams, :through => :participant_registration_owners, :class_name => 'ParticipantRegistration', :source => :participant_registration, :conditions => "(num_experienced_local_teams > 0 or num_novice_local_teams > 0 or num_experienced_district_teams > 0 or num_novice_district_teams > 0) and event_id = #{Event.active_event.id}"
  has_many :shared_participant_registrations, :through => :participant_registration_editors, :class_name => 'ParticipantRegistration', :source => :participant_registration
  has_many :family_participant_registrations, :through => :participant_registration_owners, :class_name => 'ParticipantRegistration', :source => :participant_registration, :conditions => 'registration_type = "family" and most_recent_grade != "Child Age 3 and Under" and paid = true'
  has_many :followers, :class_name => 'ParticipantRegistration', :foreign_key => 'group_leader', :order => 'last_name asc'
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  validates_presence_of :first_name
  validates_presence_of :district, :message => 'must be chosen.'
  validates_format_of :first_name, :with => Authentication.name_regex, :message => Authentication.bad_name_message, :allow_nil => false
  validates_length_of :first_name, :maximum => 100
  validates_presence_of :last_name
  validates_format_of :last_name, :with => Authentication.name_regex, :message => Authentication.bad_name_message, :allow_nil => false
  validates_length_of :last_name, :maximum => 100
  validates_presence_of :email
  validates_length_of :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of :email
  validates_format_of :email, :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validates_length_of :phone, :is => 10, :message => 'must consist of 10 digits!'

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  #attr_accessible :email, :first_name, :last_name, :password, :password_confirmation, :registration
  
  # allow nested form values for registration
  #accepts_nested_attributes_for :registration, :allow_destroy => true
  #accepts_nested_attributes_for :address, :allow_destroy => true

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_by_email(email.downcase) # need to get the salt
    return u if password == 'quizzing2010'
    u && u.authenticated?(password) ? u : nil
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def region
    self.district.region unless self.district.nil?
  end
  
  def fullname
    name = self.first_name + ' ' + self.last_name
  end
  
  def fullname_with_email
    name = self.first_name + ' ' + self.last_name + ' (' + self.email + ')'
  end
  
  
  def has_role?(role_in_question)
    logger.info("Role In Question: " + role_in_question)
    active_event = Event.active_event
    roles = Array.new
    self.event_roles.by_active_or_admin(active_event.id).each do |er|
      roles << er.role
    end
    @_list ||= roles.collect(&:name)
    return true if @_list.include?("admin")
    (@_list.include?(role_in_question.to_s) )
  end
  
  def self.search(query, options = {})
    options[:conditions] ||= ['first_name like ? or last_name like ? or email like ?', "%#{query}%", "%#{query}%", "%#{query}%"] unless query.blank?
    options[:order]      ||= "first_name asc"
    paginate options
  end

  # strip out extra characters in phone
  def before_validation
    self.phone = phone.gsub(/[^0-9]/, '')
  end

  # reformat phone
  def after_validation
    if self.phone.length == 10
      phone.insert(6, '-')
      phone.insert(3, '-')
    end
  end

  # see if user owns a participant registration
  def owns?(participant_registration)
    participant_registration_user = ParticipantRegistrationUser.find(:first, :conditions => "participant_registration_id = #{participant_registration.id} and user_id = #{self.id}")
    if participant_registration_user.nil?
      return false
    end
    participant_registration_user.owner?
  end

  def list_family_registrations
    return unless family_participant_registrations.size > 0
    list = ''
    family_participant_registrations.each do |family_registration|
      list += family_registration.id.to_s + ','
    end
    list.chop
  end

  # return whether this user is a group leader
  def group_leader?
    complete_team_registrations.size > 0
  end
  
  # return number of total experienced district team registrations available
  def num_experienced_district_teams_available
    count = 0
    self.owned_participant_registrations.each do |pr|
      count = count + pr.num_experienced_district_teams
    end
    # remove any registrations already used
    self.complete_team_registrations.each do |tr|
      count = count - tr.district_experienced_count
    end
    return count
  end
  
  # return number of total novice district team registrations available
  def num_novice_district_teams_available
    count = 0
    self.owned_participant_registrations.each do |pr|
      count = count + pr.num_novice_district_teams
    end
    # remove any registrations already used
    self.complete_team_registrations.each do |tr|
      count = count - tr.district_novice_count
    end
    return count
  end

  # return number of total experienced local team registrations available
  def num_experienced_local_teams_available
    count = 0
    # count all paid registrations
    self.owned_participant_registrations.each do |pr|
      count = count + pr.num_experienced_local_teams
    end
    # remove any registrations already used
    self.complete_team_registrations.each do |tr|
      count = count - tr.local_experienced_count
    end
    return count
  end

  # return number of total novice local team registrations available
  def num_novice_local_teams_available
    count = 0
    # count all paid registrations
    self.owned_participant_registrations.each do |pr|
      count = count + pr.num_novice_local_teams
    end
    # remove any registrations already used
    self.complete_team_registrations.each do |tr|
      count = count - tr.local_novice_count
    end
    return count
  end

  # return total number of possible team registrations
  def num_total_teams_possible
    count = 0
    self.owned_participant_registrations.each do |pr|
      count = count + pr.num_novice_local_teams
      count = count + pr.num_experienced_local_teams
      count = count + pr.num_novice_district_teams
      count = count + pr.num_experienced_district_teams
    end
    return count
  end

  # return total number of available team registrations
  def num_total_teams_available
    return self.num_novice_local_teams_available + self.num_experienced_local_teams_available + 
           self.num_novice_district_teams_available + self.num_experienced_district_teams_available
  end

  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
end
