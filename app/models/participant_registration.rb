class ParticipantRegistration < ActiveRecord::Base
  belongs_to :district
  belongs_to :school
  belongs_to :building
  belongs_to :ministry_project
  belongs_to :event
  has_many :participant_registration_users
  has_one :owner, :through => :participant_registration_users, :class_name => 'User', :source => :user, :conditions => 'owner = true'
  has_many :users, :through => :participant_registration_users
  has_many :shared_participant_registration_users, :class_name => 'ParticipantRegistrationUser', :conditions => 'owner = false'
  has_many :shared_users, :through => :shared_participant_registration_users, :class_name => 'User', :source => :user
  has_and_belongs_to_many :teams
  has_many :coached_teams, :class_name => 'Team', :foreign_key => 'coach_id'
  has_and_belongs_to_many :registration_options
  belongs_to :team1, :class_name => 'Team', :foreign_key => 'team1_id'
  belongs_to :team2, :class_name => 'Team', :foreign_key => 'team2_id'
  belongs_to :team3, :class_name => 'Team', :foreign_key => 'team3_id'

  # keep track of changes
  acts_as_audited :protect => false

  # serialize our audit log
  serialize :audit

  # extra accessors to keep track of partial payment amount and to do validation
  attr_accessor :payment_type
  attr_accessor :partial_amount

  # validations
  validates_presence_of :registration_type
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :gender, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_inclusion_of :over_18, :in => [true, false], :if => "self.coach? or self.on_campus?", :message => "must be selected", :unless => "self.using_short_registration?"
  validates_inclusion_of :over_9, :in => [true, false], :if => "self.quizzer? or self.on_campus?", :message => "must be selected", :unless => "self.using_short_registration?"
  validates_presence_of :most_recent_grade, :if => "self.quizzer?", :unless => "self.using_short_registration?"
  validates_presence_of :graduation_year, :if => "self.quizzer?", :unless => "self.using_short_registration?"
  validates_presence_of :street, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :city, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :state, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :zipcode, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :country, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :home_phone, :unless => "self.using_short_registration?"
  validates_presence_of :mobile_phone
  validates_presence_of :emergency_contact_name, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :emergency_contact_number, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :emergency_contact_relationship, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :local_church, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :district
  validates_presence_of :group_leader_text, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :coach_name, :if => "self.quizzer?", :unless => "self.using_short_registration?"
  validates_inclusion_of :planning_on_coaching, :in => [true, false], :if => "self.official? or self.staff?", :message => "must be selected", :unless => "self.using_short_registration?"
  validates_inclusion_of :planning_on_officiating, :in => [true, false], :if => "self.coach?", :message => "must be selected", :unless => "self.using_short_registration?"
  validates_presence_of :shirt_size, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :travel_type, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :travel_type_details, :if => "self.travel_type == 'I am flying to the event.'", :unless => "self.using_short_registration?"
  validates_presence_of :understand_refund_policy, :if => "self.quizzer? or self.coach? or self.official? or self.on_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :understand_form_completion, :if => "!self.off_campus?", :unless => "self.using_short_registration?"
  validates_presence_of :understand_background_check, :if => "!self.off_campus? and !self.quizzer? and !self.on_campus_under3?", :unless => "self.using_short_registration?"

  HUMANIZED_ATTRIBUTES = {:street => "Address", :home_phone => "Primary Phone", :mobile_phone => "Phone", :district => "District and Field", :group_leader_text => "Group Leader"}

  # This is purposefully imperfect -- it's just a check for bogus input. See
  # http://www.regular-expressions.info/email.html
  RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
  #RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  MSG_EMAIL_BAD   = "should look like an email address."

  # named scopes
  named_scope :housing_complete, {
    :conditions => "building_id is not null and building_id != '' and room is not null and room != ''"
  }
  
  named_scope :housing_incomplete, {
    :conditions => "building_id is null or building_id = '' or room is null or room = ''"
  }

  named_scope :background_check_complete, {
    :conditions => "background_check = true and registration_type in ('core_staff','volunteer','official')"
  }

  named_scope :background_check_incomplete, {
    :conditions => "background_check = false and registration_type in ('core_staff','volunteer','official')"
  }

  named_scope :medical_liability_complete, {
    :conditions => "medical_liability = true"
  }

  named_scope :medical_liability_incomplete, {
    :conditions => "medical_liability = false"
  }

  named_scope :nazsafe_complete, {
    :conditions => "nazsafe = true and registration_type in ('core_staff','volunteer','official')"
  }

  named_scope :nazsafe_incomplete, {
    :conditions => "nazsafe = false and registration_type in ('core_staff','volunteer','official')"
  }

  named_scope :ministry_project_complete, {
    :conditions => "ministry_project_id is not null and ministry_project_id != ''"
  }

  named_scope :ministry_project_complete_with_group, {
    :conditions => "ministry_project_id is not null and ministry_project_id != '' and ministry_project_group is not null and ministry_project_group != ''"
  }

  named_scope :ministry_project_incomplete, {
    :conditions => "ministry_project_id is null or ministry_project_id = ''"
  }

  named_scope :by_registration_type, lambda { |registration_type|
    { :conditions => ["registration_type = ?", registration_type] }
  }

  named_scope :by_building, lambda { |building_id|
    { :conditions => ["building_id = ?", building_id] }
  }

  named_scope :by_ministry_project, lambda { |ministry_project_id|
    { :conditions => ["ministry_project_id = ?", ministry_project_id] }
  }

  named_scope :by_district, lambda { |district_id|
    { :conditions => ["district_id = ?", district_id] }
  }

  named_scope :by_region, lambda { |region_id| {
      :joins => "INNER JOIN districts ON participant_registrations.district_id = districts.id INNER JOIN regions on districts.region_id = regions.id",
      :conditions => ["region_id = ?", region_id],
    }
  }

  named_scope :by_group_leader, lambda { |group_leader|
    { :conditions => ["group_leader = ?", group_leader] }
  }

  named_scope :by_grade, lambda { |grade|
    { :conditions => ["most_recent_grade = ?", grade] }
  }

  named_scope :ordered_by_last_name, {
    :order => 'last_name asc, first_name asc'
  }

  named_scope :ordered_by_first_name, {
    :order => 'first_name asc, last_name asc'
  }
  
  named_scope :needs_housing, {
    :conditions => "registration_type != 'off-campus'"
  }

  named_scope :ordered_by_building_room_last_name, {
    :select => "participant_registrations.*, building_id is null as buildingisnull, room is null as roomisnull",
    :joins => "LEFT JOIN buildings ON participant_registrations.building_id = buildings.id",
    :order => "buildingisnull asc, roomisnull asc, buildings.name asc, room asc, last_name asc"
  }

  named_scope :ordered_by_room, {
    :order => "room asc"
  }

  named_scope :search, lambda { |query| {
      :conditions => "first_name like '%#{query}%' or last_name like '%#{query}%' or email like '%#{query}%'"
    }
  }

  named_scope :complete, {
    :conditions => "paid = 1"
  }

  named_scope :incomplete, {
    :conditions => "paid = 0"
  }

  named_scope :by_division, lambda { |division_id| {
      :joins => "LEFT JOIN teams t1 ON participant_registrations.team1_id = t1.id " +
        "LEFT JOIN teams t2 ON participant_registrations.team2_id = t2.id " +
        "LEFT JOIN teams t3 ON participant_registrations.team3_id = t3.id ",
      :conditions => "t1.division_id = '#{division_id}' or t2.division_id = '#{division_id}' or t3.division_id = '#{division_id}'"
    }
  }

  named_scope :has_special_needs, {
    :conditions => "special_needs_food_allergies = 1 OR special_needs_handicap_accessible = 1 OR special_needs_hearing_impaired = 1 OR special_needs_vision_impaired = 1 OR special_needs_other = 1"
  }

  named_scope :no_team, {
    :joins      => "LEFT JOIN participant_registrations_teams ON participant_registrations.id = participant_registrations_teams.participant_registration_id",
    :conditions => "participant_registrations_teams.participant_registration_id IS NULL and registration_type = 'quizzer'",
    :select     => "DISTINCT participant_registrations.*",
    :order      => "last_name asc"
  }
  
  named_scope :needs_shuttle, {
    :conditions => "participant_registrations.airport_transportation = 1"
  }

  named_scope :bought_shuttle, {
    :joins      => "LEFT JOIN participant_registrations_registration_options on participant_registrations.id = participant_registrations_registration_options.participant_registration_id LEFT JOIN registration_options on participant_registrations_registration_options.registration_option_id = registration_options.id",
    :conditions => "registration_options.item = 'shuttle'",
    :select     => "DISTINCT participant_registrations.*",
    :order      => "last_name asc"
  }
  
  named_scope :has_linens_or_pillow, {
    :conditions => "participant_registrations.linens = 1 or participant_registrations.pillow = 1"
  }
  
  named_scope :no_flight_info, {
    :conditions => "participant_registrations.airline_arrival_date is null or airline_departure_date is null"
  }

  named_scope :by_gender, lambda { |gender| {
      :conditions => "participant_registrations.gender = '#{gender}'"
    }
  }

  named_scope :by_event, lambda { |event_id|
    { :conditions => ["participant_registrations.event_id = ?", event_id] }
  }

  named_scope :group_leader_undefined, {
    :conditions => "group_leader is null or group_leader = ''"
  }

  named_scope :group_leader_defined, {
    :conditions => "group_leader is not null and group_leader != ''"
  }

  named_scope :is_flying, {
    :conditions => "travel_type = 'I am flying to the event.'"
  }

  named_scope :is_driving, {
    :conditions => "travel_type = 'I am driving to the event.'"
  }

  named_scope :inactive, {
    :conditions => "registration_type = 'inactive'"
  }

  named_scope :active, {
    :conditions => "registration_type != 'inactive'"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def using_short_registration?
    Event.active_event.use_short_registration?
  end

  # strip out extra characters in mobile phone
  def before_validation
    self.home_phone = '' if self.home_phone.nil?
    temp_home_phone = self.home_phone
    unless self.home_phone =~ /^\d{3}-\d{3}-\d{4}$/
      self.home_phone = self.home_phone.gsub(/[^0-9]/, '')
      if self.home_phone.length == 10
        self.home_phone.insert(6, '-')
        self.home_phone.insert(3, '-')
      else
        self.home_phone = temp_home_phone
      end
    end
    self.mobile_phone = '' if self.mobile_phone.nil?
    temp_mobile_phone = self.mobile_phone
    unless self.mobile_phone =~ /^\d{3}-\d{3}-\d{4}$/
      self.mobile_phone = self.mobile_phone.gsub(/[^0-9]/, '')
      if self.mobile_phone.length == 10
        self.mobile_phone.insert(6, '-')
        self.mobile_phone.insert(3, '-')
      else
        self.mobile_phone = temp_mobile_phone
      end
    end
    self.school_fax = '' if self.school_fax.nil?
    temp_school_fax = self.school_fax
    unless self.school_fax =~ /^\d{3}-\d{3}-\d{4}$/
      self.school_fax = self.school_fax.gsub(/[^0-9]/, '')
      if self.school_fax.length == 10
        self.school_fax.insert(6, '-')
        self.school_fax.insert(3, '-')
      else
        self.school_fax = temp_school_fax
      end
    end
  end
  
  # provide full name of participant registering
  def full_name
    first_name + ' ' + last_name
  end

  # provide full name of participant registering in the format last_name, first_name
  def full_name_reversed
    last_name + ', ' + first_name
  end

  # return housing for this participant in the format 'building room'
  def housing
    unless building.blank?
      return building.name + ' ' + room
    end
    return ''
  end

  # allow setting of a current user for audit log purposes
  def audit_user=(user)
    @audit_user = user
  end

  # return whether this participant registration is complete or not
  def complete?
    self.amount_due == 0
  end

  # returns if this registration is for a quizzer
  def quizzer?
    self.registration_type == 'quizzer'
  end

  # returns if this registration is for a coach
  def coach?
    self.registration_type == 'coach'
  end

  # returns if this registration is for a volunteer
  def volunteer?
    self.registration_type == 'volunteer'
  end

  # returns if this registration is for an official
  def official?
    self.registration_type == 'official'
  end

  # returns if this registration is for a core staff member
  def core_staff?
    self.registration_type == 'core_staff'
  end

  # returns if this registration is for a staff member
  def staff?
    self.registration_type == 'staff'
  end

  # returns if this registration is for an off-campus guest
  def off_campus?
    self.registration_type == 'off-campus'
  end

  # returns if this registration is for an on-campus guest
  def on_campus?
    self.registration_type == 'on-campus'
  end

   # returns if this registration is for an on-campus guest under 3
   def on_campus_under3?
    self.registration_type == 'on-campus-under3'
  end

  # returns if this registration is for an exhibitor
  def exhibitor?
    self.registration_type == 'exhibitor'
  end

  # returns if this registration is inactive
  def inactive?
    self.registration_type == 'inactive'
  end

  # returns if this registration is active
  def active?
    self.registration_type != 'inactive'
  end

  # returns if this registration has flying selected as travel_type
  def flying?
    self.travel_type == 'I am flying to the event.'
  end

  # returns if this registration has driving selected as travel_type
  def driving?
    self.travel_type == 'I am driving to the event.'
  end

  # return other family registrations related to this one
  def family_participant_registrations
    if self.registration_type != 'family' or self.family_registrations.blank?
      return Array.new
    end
    ParticipantRegistration.find(:all, :conditions => "id in (#{self.family_registrations})")
  end

  # return a comma separated list of family registrations that are related to this one
  def related_family_registrations
    if self.registration_type != 'family'
      return ''
    end

    list = ''
    self.owner.family_participant_registrations.each do |family_registration|
      list += family_registration.id.to_s + ','
    end
    list.chop
  end

  # returns if this registration is for a child
  def child?
    self.most_recent_grade == 'Child Age 3 and Under' or self.most_recent_grade == 'Child Age 4-12'
  end

  # returns if this registration is for a small child
  def small_child?
    self.most_recent_grade == 'Child Age 3 and Under'
  end

  # return if this registration has a discount applied
  def has_discount?
    return false if discount_in_cents.nil?
    discount_in_cents > 0
  end

  # Return the registration type as a formatted value
  def formatted_registration_type
    types = {
      'quizzer' => 'Quizzer',
      'coach' => 'Coach',
      'official' => 'Official / Volunteer',
      'staff' => 'Staff / Intern',
      'on-campus overnight guest' => 'On Campus Overnight Guest',
      'off-campus spectator' => 'Off Campus Spectator',
      'inactive' => 'Inactive'
    }
    return !registration_type.nil? ? types[registration_type] : ''
  end

  # returns the name of this participant's group leader
  def group_leader_name
    leader = ''
    if self.group_leader.to_i == -1
      leader = 'Group Leader Not Listed'
    elsif self.group_leader.to_i == -2
      leader = 'Group Leader Not Known'
    elsif self.group_leader.to_i == -3
      leader = 'No Group Leader'
    elsif self.group_leader.to_i == -4
      leader = 'Staff'
    elsif self.group_leader.to_i == -5
      leader = 'Official'
    elsif self.group_leader.to_i == -6
      leader = 'Volunteer'
    elsif self.group_leader.to_i == -7
      leader = 'Representative'
    else
      unless self.group_leader.blank? or self.group_leader.nil? or self.group_leader == 0
        user = User.find(self.group_leader.to_i)
        leader = user.fullname
      end
    end
    leader
  end

  # returns whether the needed registration requires a background check
  def needs_background_check?
    core_staff? or volunteer? or official?
  end

  # returns comma separated list of divisions this participant registration is in.
  def division_list
    list = ''
    unless team1.nil?
      list += team1.division.name + ', '
    end
    unless team2.nil?
      list += team2.division.name + ', '
    end
    unless team3.nil?
      list += team3.division.name + ', '
    end
    list.chop!.chop! unless list.blank?
  end

  # find the participant's room keycode based
  # upon the build / room they're staying
  def keycode
    if !self.building_id.nil?
      housing_room = HousingRoom.find(:first, :conditions => "building_id = '#{self.building.id}' and number = '#{room}'")
      !housing_room.blank? ? housing_room.keycode : ''
    else
      ''
    end
      
  end

  # return whether this participant needs housing
  def needs_housing?
    if self.exhibitor? and self.exhibitor_housing == 'on_campus'
      return true
    elsif !self.exhibitor? and self.participant_housing == 'meals_and_housing'
      return true
    else
      return false
    end
  end

  # return whether this participant needs meals
  def needs_meals?
    if self.exhibitor? and self.exhibitor_housing == 'on_campus'
      return true
    elsif self.exhibitor? and self.exhibitor_housing == 'off_campus_with_meals'
      return true
    elsif !self.exhibitor? and self.participant_housing == 'meals_and_housing'
      return true
    elsif !self.exhibitor? and self.participant_housing == 'meals_only'
      return true
    else
      return false
    end
  end

  private

  # returns whether we should ask about food allergies
  def check_food_allergies?
    if self.registration_type == 'quizzer' or self.registration_type == 'coach'
      if self.participant_housing == 'none'
        return false
      end
    end
    if self.registration_type == 'exhibitor'
      if self.exhibitor_housing == 'off_campus_without_meals'
        return false
      end
    end
    return true
  end
end
