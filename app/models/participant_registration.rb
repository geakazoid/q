class ParticipantRegistration < ActiveRecord::Base
  belongs_to :district
  belongs_to :school
  belongs_to :building
  belongs_to :ministry_project
  has_many :participant_registration_users
  has_many :registration_items
  has_many :payments
  has_one :owner, :through => :participant_registration_users, :class_name => 'User', :source => :user, :conditions => 'owner = true'
  has_many :users, :through => :participant_registration_users
  has_many :shared_participant_registration_users, :class_name => 'ParticipantRegistrationUser', :conditions => 'owner = false'
  has_many :shared_users, :through => :shared_participant_registration_users, :class_name => 'User', :source => :user
  belongs_to :team1, :class_name => 'Team', :foreign_key => 'team1_id'
  belongs_to :team2, :class_name => 'Team', :foreign_key => 'team2_id'
  belongs_to :team3, :class_name => 'Team', :foreign_key => 'team3_id'

  # keep track of changes
  acts_as_audited :protect => false

  # allow nested form values for registration items
  accepts_nested_attributes_for :registration_items, :allow_destroy => true

  # serialize our audit log
  serialize :audit

  # extra accessors to keep track of partial payment amount and to do validation
  attr_accessor :payment_type
  attr_accessor :partial_amount

  HUMANIZED_COLUMNS = {:street => "Address"}

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
    :order => 'last_name asc'
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
    :conditions => "special_needs = 'Yes'"
  }

  # validations
  validates_presence_of :registration_type, :message => "must be chosen."
  validates_presence_of :first_name, :message => "can't be blank."
  validates_presence_of :last_name, :message => "can't be blank."
  validates_presence_of :email, :message => "can't be blank."
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_presence_of :street, :message => "can't be blank."
  validates_presence_of :city, :message => "can't be blank."
  validates_presence_of :state, :message => "must be chosen."
  validates_presence_of :zipcode, :message => "can't be blank."
  validates_presence_of :country, :message => "can't be blank."
  validates_presence_of :gender, :message => "must be chosen."
  validates_presence_of :shirt_size, :message => "must be chosen."
  validates_presence_of :most_recent_grade, :message => "must be chosen."
  validates_presence_of :guardian, :message => "can't be blank.", :if => :child?
  validates_presence_of :home_phone, :message => "can't be blank."
  validates_presence_of :mobile_phone, :message => "can't be blank."
  validates_format_of :home_phone, :with => /^\d{3}-\d{3}-\d{4}$/, :message => "must consist of 10 digits."
  validates_format_of :mobile_phone, :with => /^\d{3}-\d{3}-\d{4}$/, :message => "must consist of 10 digits."
  validates_presence_of :group_leader, :message => "must be chosen."
  validates_presence_of :local_church, :message => "can't be blank."
  validates_presence_of :district, :message => "must be chosen."
  validates_presence_of :special_needs, :message => "You must answer whether you have any special needs."
  validates_presence_of :food_allergies, :message => "You must answer whether you have any food allergies.", :if => :check_food_allergies?
  validates_presence_of :promotion_agree, :message => "You must agree/disagree to promotion."
  validates_presence_of :airline_arrival_date, :message => "can't be blank.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_presence_of :airline_arrival_time, :message => "can't be blank.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_presence_of :airline_departure_date, :message => "can't be blank.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_presence_of :airline_departure_time, :message => "can't be blank.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_presence_of :arrival_airline, :message => "must be chosen.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_presence_of :departure_airline, :message => "must be chosen.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_presence_of :arrival_flight_number, :message => "can't be blank.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_presence_of :departure_flight_number, :message => "can't be blank.", :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_format_of :airline_arrival_date, :with => /^(0?6\/30|0?7\/0?1|0?7\/0?2|0?7\/0?3|0?7\/0?4|0?7\/0?5|0?7\/0?6|0?7\/0?7)$/, :message => "Arrival date should be in the format MM/DD and no earlier than 06/30.", :allow_blank => true, :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_format_of :airline_arrival_time, :with => /^(1|01|2|02|3|03|4|04|5|05|6|06|7|07|8|08|9|09|10|11|12):[0-5][0-9] ?(AM|PM|am|pm)$/, :message => "Arrival time should be in the format HH:MM AM/PM.", :allow_blank => true, :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_format_of :airline_departure_date, :with => /^(0?6\/30|0?7\/0?1|0?7\/0?2|0?7\/0?3|0?7\/0?4|0?7\/0?5|0?7\/0?6|0?7\/0?7|0?7\/0?8)$/, :message => "Departure date should be in the format MM/DD and no later than 07/08.", :allow_blank => true, :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_format_of :airline_departure_time, :with => /^(1|01|2|02|3|03|4|04|5|05|6|06|7|07|8|08|9|09|10|11|12):[0-5][0-9] ?(AM|PM|am|pm)$/, :message => "Departure time should be in the format HH:MM AM/PM.", :allow_blank => true, :if => Proc.new { |participant_registration| participant_registration.flying? }
  validates_format_of :driving_arrival_date, :with => /^(0?6\/30|0?7\/0?1|0?7\/0?2|0?7\/0?3|0?7\/0?4|0?7\/0?5|0?7\/0?6|0?7\/0?7)$/, :message => "Arrival date should be in the format MM/DD and no earlier than 06/30.", :allow_blank => true, :if => Proc.new { |participant_registration| participant_registration.driving? }
  validates_format_of :driving_arrival_time, :with => /^(1|01|2|02|3|03|4|04|5|05|6|06|7|07|8|08|9|09|10|11|12):[0-5][0-9] ?(AM|PM|am|pm)$/, :message => "Arrival time should be in the format HH:MM AM/PM.", :allow_blank => true, :if => Proc.new { |participant_registration| participant_registration.driving? }
  validates_numericality_of :num_extra_group_photos, :message => "Quantity of extra group photos must be a number.", :allow_blank => true
  validates_numericality_of :num_dvd, :message => "Quantity of DVD highlight videos must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_youth_small_shirts, :message => "Quantity of youth small t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_youth_medium_shirts, :message => "Quantity of youth medium t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_youth_large_shirts, :message => "Quantity of youth large t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_small_shirts, :message => "Quantity of small t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_medium_shirts, :message => "Quantity of medium t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_large_shirts, :message => "Quantity of large t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_xlarge_shirts, :message => "Quantity of x-large t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_2xlarge_shirts, :message => "Quantity of 2x-large t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_3xlarge_shirts, :message => "Quantity of 3x-large t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_4xlarge_shirts, :message => "Quantity of 4x-large t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_extra_5xlarge_shirts, :message => "Quantity of 5x-large t-shirts must be a number.", :allow_blank => true
  validates_numericality_of :num_sv_tickets, :message => "Quantity of Splash Valley tickets must be a number.", :allow_blank => true
  validates_presence_of :school_fax, :message => "can't be blank.", :if => :exhibitor?
  validates_format_of :school_fax, :with => /^\d{3}-\d{3}-\d{4}$/, :message => "must consist of 10 digits.", :if => :exhibitor?

  # custom validations
  validate do |participant_registration|
    participant_registration.errors.add(:most_recent_grade, "You must select a valid grade.") if participant_registration.quizzer? and !['6th','7th','8th','9th','10th','11th','12th'].include?(participant_registration.most_recent_grade)
    participant_registration.errors.add(:most_recent_grade, "You must choose adult for age group.") if participant_registration.official? and participant_registration.most_recent_grade != 'Adult'
    participant_registration.errors.add(:most_recent_grade, "You must choose adult for age group.") if participant_registration.volunteer? and participant_registration.most_recent_grade != 'Adult'
    participant_registration.errors.add(:most_recent_grade, "You must choose adult for age group.") if participant_registration.core_staff? and participant_registration.most_recent_grade != 'Adult'
    participant_registration.errors.add(:most_recent_grade, "You must choose adult for age group.") if participant_registration.exhibitor? and participant_registration.most_recent_grade != 'Adult'
    participant_registration.errors.add(:special_needs_details, "You must enter details regarding your special needs.") if participant_registration.special_needs == "Yes" and participant_registration.special_needs_details.blank?
    participant_registration.errors.add(:food_allergies_details, "You must enter details regarding your food allergies.") if participant_registration.food_allergies == "Yes" and participant_registration.food_allergies_details.blank?

    if participant_registration.quizzer? or participant_registration.coach?
      # team validations
      # did we select at least one team?
      #if participant_registration.team1_id.blank? and participant_registration.team2_id.blank? and participant_registration.team3_id.blank?
      #  participant_registration.errors.add(:team1_id, "You must choose at least one team.")
      #end

      # did we select a team twice?
      if participant_registration.team1_id == participant_registration.team2_id and !participant_registration.team1_id.blank?
        participant_registration.errors.add(:team2_id, "You cannot select the same team twice.")
      end
      if participant_registration.team1_id == participant_registration.team3_id and !participant_registration.team1_id.blank?
        participant_registration.errors.add(:team3_id, "You cannot select the same team twice.")
      end
      if participant_registration.team2_id == participant_registration.team3_id and !participant_registration.team2_id.blank?
        participant_registration.errors.add(:team3_id, "You cannot select the same team twice.")
      end 
    end

    if participant_registration.quizzer?
      # did we select a regional team and a novice team?
      team1 = Team.find(participant_registration.team1_id) unless participant_registration.team1_id.blank?
      team2 = Team.find(participant_registration.team2_id) unless participant_registration.team2_id.blank?
      team3 = Team.find(participant_registration.team3_id) unless participant_registration.team3_id.blank?

      if !team1.nil? and !team2.nil? and team1.regional_team? and team2.novice_team?
        participant_registration.errors.add(:team2_id, "You cannot choose both a regional team and a novice team.")
      end
      if !team1.nil? and !team3.nil? and team1.regional_team? and team3.novice_team?
        participant_registration.errors.add(:team3_id, "You cannot choose both a regional team and a novice team.")
      end
      if !team2.nil? and !team1.nil? and team2.regional_team? and team1.novice_team?
        participant_registration.errors.add(:team1_id, "You cannot choose both a regional team and a novice team.")
      end
      if !team2.nil? and !team3.nil? and team2.regional_team? and team3.novice_team?
        participant_registration.errors.add(:team3_id, "You cannot choose both a regional team and a novice team.")
      end
      if !team3.nil? and !team1.nil? and team3.regional_team? and team1.novice_team?
        participant_registration.errors.add(:team1_id, "You cannot choose both a regional team and a novice team.")
      end
      if !team3.nil? and !team2.nil? and team3.regional_team? and team2.novice_team?
        participant_registration.errors.add(:team2_id, "You cannot choose both a regional team and a novice team.")
      end
    end

    # validate registration code if one is needed
    if participant_registration.volunteer?
      unless participant_registration.registration_code == 'VA9TXG7F'
        participant_registration.errors.add(:registration_code, "Your registration code is invalid.")
      end
    end  
    if participant_registration.official?
      unless participant_registration.registration_code == 'FZ9XZB32'
        participant_registration.errors.add(:registration_code, "Your registration code is invalid.")
      end
    end
    if participant_registration.core_staff?
      unless participant_registration.registration_code == 'CH8LN22V'
        participant_registration.errors.add(:registration_code, "Your registration code is invalid.")
      end
    end

    # validate partial_amount > 50 if paying a partial amount
    if participant_registration.payment_type == 'partial' and participant_registration.partial_amount.to_i < 50
      participant_registration.errors.add(:partial_amount, "A partial payment must be more than $50.")
    end
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

  # return total paid amount
  def total_paid_amount
    payment_amount = 0
    self.payments.each do |payment|
      payment_amount += payment.amount_in_cents
    end
    payment_amount / 100
  end

  # return registration paid amount
  def paid_registration_amount
    payment_amount = 0
    self.payments.each do |payment|
      payment_amount += payment.details['registration_amount'].to_i unless payment.details['registration_amount'].nil?
    end
    payment_amount / 100
  end

  # return extras paid amount
  def paid_extras_amount
    total_paid_amount - paid_registration_amount
  end

  # return whether we've paid for any of our registration fee
  def paid_any_registration_fee?
    # quick check for registrations that are free
    return true if paid?
    # otherwise see if we've paid anything
    paid_registration_amount > 0
  end

  # return whether we've paid for the full registration fee
  def paid_full_registration_fee?
    if self.new_record?
      return false
    else
      paid_registration_amount >= (self.registration_fee - registration_discount) / 100
    end
  end

  # return whether we've bought the passed in extra
  def bought_extra?(extra)
    bought = false
    self.payments.each do |payment|
      bought = true unless payment.details[extra].nil?
    end
    bought
  end

  # count the bought number of the passed in extra
  def count_bought_extra(extra)
    if self.new_record?
      return 0
    else
      count = 0
      self.payments.each do |payment|
        count += payment.details[extra].to_i unless payment.details[extra].nil?
      end

      return count
    end
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

  # returns if this registration is for an exhibitor
  def exhibitor?
    self.registration_type == 'exhibitor'
  end

  # returns if this registration has flying selected as travel_type
  def flying?
    self.travel_type == 'flying'
  end

  # returns if this registration has driving selected as travel_type
  def driving?
    self.travel_type == 'driving'
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

  # return the discount amount being applied to the registration fee
  def registration_discount
    return 0 if discount_in_cents.nil?
    if discount_in_cents > 0
      left_to_pay = registration_fee - (paid_registration_amount * 100)
      logger.info("Left To Pay: " + left_to_pay.to_s)
      if discount_in_cents > left_to_pay
        return left_to_pay
      else
        return discount_in_cents
      end
    end
  end

  # return the discount amount being applied to any extras
  def extras_discount
    return 0 if discount_in_cents.nil?
    if discount_in_cents > 0
      left_to_pay = registration_fee - (paid_registration_amount * 100)
      if discount_in_cents > left_to_pay
        discount_for_extras = discount_in_cents - left_to_pay
        if discount_for_extras > paid_extras_amount * 100
          return discount_for_extras - paid_extras_amount * 100
        else
          return 0
        end
      else
        return 0
      end
    end
  end

  # return the amount due for registration
  def registration_amount_due
    paid_amount = paid_registration_amount * 100
    discount = registration_discount ? registration_discount : 0
    payment_remaining = (registration_fee - paid_amount - discount) / 100
  end

  # return the amount due for extras
  def extras_amount_due
    discount = extras_discount ? extras_discount : 0
    payment_remaining = (extras_fee - discount) / 100
    payment_remaining = 0 if payment_remaining < 0
    return payment_remaining
  end

  # return the total amount due
  def total_amount_due
    registration_amount_due + extras_amount_due
  end

  # return the discount amount being applied
  # this is in dollars
  def applied_discount
    return 0 if discount_in_cents.nil?
    discount_in_cents / 100
  end

  def arrival_shuttle_amount
    return false unless bought_extra?('need_arrival_shuttle')
    if core_staff? or small_child?
      return 0
    else
      return 3
    end
  end

  def departure_shuttle_amount
    return false unless bought_extra?('need_departure_shuttle')
    if core_staff? or small_child?
      return 0
    else
      return 3
    end
  end

  def housing_sunday_amount
    return false unless bought_extra?('housing_sunday')
    if core_staff? or small_child?
      return 0
    else
      return 10
    end
  end

  def housing_saturday_amount
    return false unless bought_extra?('housing_saturday')
    if core_staff? or small_child?
      return 0
    else
      return 10
    end
  end

  def breakfast_monday_amount
    return false unless bought_extra?('breakfast_monday')
    bought_breakfast = false
    bought_lunch = false

    # loop through our payments to find out when we purchased each meal on monday
    # this is a total hack, but i'm pretty sure this is the best way to handle it.
    # boo on me.
    meals_bought_together = false
    breakfast_bought_first = false
    lunch_bought_first = false
    # if we're core staff or a child we dont care about the price
    if !core_staff? and !small_child?
      payments.each do |payment|
        if !meals_bought_together and !breakfast_bought_first and !lunch_bought_first
          bought_breakfast = false
          bought_lunch = false
          payment.details.each do |key,detail|
            if key == 'breakfast_monday'
              bought_breakfast = true
            end

            if key == 'lunch_monday'
              bought_lunch = true
            end
          end

          if bought_breakfast and bought_lunch
            meals_bought_together = true
          elsif bought_breakfast
            breakfast_bought_first = true
          elsif bought_lunch
            lunch_bought_first = true
          end
        end
      end

      if lunch_bought_first
        return 4
      else
        return 5
      end
    else
      return 0
    end
  end

  def lunch_monday_amount
    return false unless bought_extra?('lunch_monday')
    bought_breakfast = false
    bought_lunch = false

    # loop through our payments to find out when we purchased each meal on monday
    # this is a total hack, but i'm pretty sure this is the best way to handle it.
    # boo on me.
    meals_bought_together = false
    breakfast_bought_first = false
    lunch_bought_first = false
    # if we're core staff or a child we dont care about the price
    if !core_staff? and !small_child?
      payments.each do |payment|
        if !meals_bought_together and !breakfast_bought_first and !lunch_bought_first
          bought_breakfast = false
          bought_lunch = false
          payment.details.each do |key,detail|
            if key == 'breakfast_monday'
              bought_breakfast = true
            end

            if key == 'lunch_monday'
              bought_lunch = true
            end
          end

          if bought_breakfast and bought_lunch
            meals_bought_together = true
          elsif bought_breakfast
            breakfast_bought_first = true
          elsif bought_lunch
            lunch_bought_first = true
          end
        end
      end

      if breakfast_bought_first or meals_bought_together
        return 5
      else
        return 6
      end
    else
      return 0
    end
  end

  def floor_fan_amount
    return false unless bought_extra?('need_floorfan')
    if core_staff? or small_child?
      return 0
    else
      return 12
    end
  end

  def pillow_amount
    return false unless bought_extra?('need_pillow')
    if core_staff? or small_child?
      return 0
    else
      return 8
    end
  end

  # Return the registration type as a formatted value
  def formatted_registration_type
    return 'Core Staff' if registration_type == 'core_staff'
    return registration_type.capitalize
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
    else
      unless self.group_leader.blank?
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

  # returns a formatted list of extra shirts this registration bought
  def extra_shirts
    text = ''
    if count_bought_extra('num_extra_youth_small_shirts') > 0
      text += 'Youth Small (' + count_bought_extra('num_extra_youth_small_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_youth_medium_shirts') > 0
      text += 'Youth Medium (' + count_bought_extra('num_extra_youth_medium_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_youth_large_shirts') > 0
      text += 'Youth Large (' + count_bought_extra('num_extra_youth_large_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_small_shirts') > 0
      text += 'Small (' + count_bought_extra('num_extra_small_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_medium_shirts') > 0
      text += 'Medium (' + count_bought_extra('num_extra_medium_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_large_shirts') > 0
      text += 'Large (' + count_bought_extra('num_extra_large_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_xlarge_shirts') > 0
      text += 'X-Large (' + count_bought_extra('num_extra_xlarge_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_2xlarge_shirts') > 0
      text += '2X-Large (' + count_bought_extra('num_extra_2xlarge_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_3xlarge_shirts') > 0
      text += '3X-Large (' + count_bought_extra('num_extra_3xlarge_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_4xlarge_shirts') > 0
      text += '4X-Large (' + count_bought_extra('num_extra_4xlarge_shirts').to_s + '), '
    end
    if count_bought_extra('num_extra_5xlarge_shirts') > 0
      text += '5X-Large (' + count_bought_extra('num_extra_5xlarge_shirts').to_s + '), '
    end
    text.chop!.chop! unless text.blank?
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