class TeamRegistration < ActiveRecord::Base
  belongs_to :user
  belongs_to :district
  belongs_to :event
  has_one :payment
  has_many :teams, :dependent => :destroy

  accepts_nested_attributes_for :teams, :allow_destroy => true

  serialize :audit

  # This is purposefully imperfect -- it's just a check for bogus input. See
  # http://www.regular-expressions.info/email.html
  RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
  #RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  MSG_EMAIL_BAD   = "should look like an email address."
    
  # validations
  validates_presence_of :district
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :email
  validates_length_of :phone, :is => 10, :message => 'must consist of 10 digits!'
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  # custom validations
  #validate_on_create :only_two_regional_teams
  validate_on_create :has_regional_code

  # before save to store out audit information
  before_save :prepare_audit

  HUMANIZED_ATTRIBUTES = {
    "Teams.name" => "Team name"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
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
  
  # validate that we have a code if a regional team is selected.
  def has_regional_code
    regional_a_division = Division.find_by_name('Regional A')
    regional_b_division = Division.find_by_name('Regional B')
    registering_regional_team = false
    # look through teams on this registration to see if any of them
    # are regional teams.
    self.teams.each do |team|
      if team.division == regional_a_division
        registering_regional_team = true
      end
      if team.division == regional_b_division
        registering_regional_team = true
      end
    end
    if !self.complete? and registering_regional_team and self.regional_code != AppConfig.regional_code
      errors.add_to_base('You must provide a code in order to register a regional team')
    end
  end

  # validate that we aren't registering more than 2 regional teams per region
  # this validation only adds an error if a user attempts to register a
  # regional team and that would put us over 2. Otherwise it does nothing.
  def only_two_regional_teams
    # we don't have a district and therefore no region
    # so we have nothing to check
    if (self.district.nil?)
      return
    end

    # find out how many teams we already have registered
    total_teams = num_regional_teams = self.district.region.num_regional_teams

    # assume we aren't registering any regional teams
    registering_regional_team = false

    regional_division = Division.find_by_name('Regional Teams')
    # look through teams on this registration to see if any of them
    # are regional teams. add to total if any are found.
    self.teams.each do |team|
      if team.division == regional_division
        registering_regional_team = true
        num_regional_teams += 1
      end
    end

    # add an error for display if needed
    if registering_regional_team and num_regional_teams > 2
      errors.add_to_base('Each region may only register 2 regional teams. ' + self.district.region.num_regional_teams.to_s + ' team(s) have already been registered.')
    end
  end
  
  # validate that the current user had available team registrations
  # this validation adds an error if a user attempts to register a
  # team or teams and doesn't have enough registrations to do so.
  def current_user_has_registrations
    if (district_experienced_count > @audit_user.num_experienced_district_teams_available)
      errors.add_to_base('You do not have enough district team registrations.')
    end
    if (district_novice_count > @audit_user.num_novice_district_teams_available)
      errors.add_to_base('You do not have enough district team registrations.')
    end
    if (local_experienced_count > @audit_user.num_experienced_local_teams_available)
      errors.add_to_base('You do not have enough local team registrations.')
    end
    if (local_novice_count > @audit_user.num_novice_local_teams_available)
      errors.add_to_base('You do not have enough local team registrations.')
    end
  end

  # return the total amount for this registration  
  def total_amount
    total = 0
    self.teams.each do |team|
      total = total + team.amount_in_cents
    end
    total / 100
  end

  # provide full name of person registering
  def full_name
    first_name + ' ' + last_name
  end

  # count of the number of regional teams being registered
  def regional_count
    team_count('Regional Teams')
  end
  
  # count of the number of district experienced teams being registered
  def district_experienced_count
    total = 0
    teams.each do |team|
      total = total + 1 if !team.division.nil? and team.division.name == 'District Experienced' and !team.discounted?
    end
    total
  end
  
  # count of the number of district novice teams being registered
  def district_novice_count
    total = 0
    teams.each do |team|
      total = total + 1 if !team.division.nil? and team.division.name == 'District Novice' and !team.discounted?
    end
    total
  end

  # count of the number of discounted district experienced teams being registered
  def district_experienced_discounted_count
    total = 0
    teams.each do |team|
      total = total + 1 if !team.division.nil? and team.division.name == 'District Experienced' and team.discounted?
    end
    total
  end

  # count of the number of discounted district novice teams being registered
  def district_novice_discounted_count
    total = 0
    teams.each do |team|
      total = total + 1 if !team.division.nil? and team.division.name == 'District Novice' and team.discounted?
    end
    total
  end
  
  # count of the number of local experienced teams being registered
  def local_experienced_count
    team_count('Local Experienced')
  end
  
  # count of the number of local novice teams being registered
  def local_novice_count
    team_count('Local Novice')
  end

  # count of district teams being registered
  def district_count
    district_novice_count + district_experienced_count + district_novice_discounted_count + district_experienced_discounted_count
  end
  
  # count of local teams being registered
  def local_count
    local_novice_count + local_experienced_count
  end

  # allow setting of a current user for audit log purposes
  def audit_user=(user)
    @audit_user = user
  end

  # return whether this team registration is complete or not
  def complete?
    self.paid?
  end
  
  private
  
  # count of the number of teams (for a division) on this registration
  def team_count(division)
    total = 0
    teams.each do |team|
      total = total + 1 if !team.division.nil? and team.division.name == division
    end
    total
  end

  # save audit information
  def prepare_audit
    if self.audit.nil?
      self.audit = Array.new
    end
    
    # create a timestamp
    timestamp = Time.now
    audit_text = timestamp.strftime("%m.%d.%Y %I:%M %p")

    # set a user if one was passed
    if !@audit_user.nil?
      audit_text << " (#{@audit_user.fullname})"
    end

    audit_text << ":"

    if self.new_record?
      # this is a create

      amount = "$%.2f" % (self.amount_in_cents / 100)
      audit_text << " Team registration created with the following values. "
      audit_text << " First Name: #{self.first_name}"
      audit_text << " Last Name: #{self.last_name}"
      audit_text << " Phone: #{self.phone}"
      audit_text << " Email: #{self.email}"
      audit_text << " Amount: #{amount}"
      audit_text << " Paid: #{self.paid}"
      audit_text << " Teams:"

      # look for teams
      i = 0
      self.teams.each do |team|
        i += 1
        audit_text << " team ##{i} - #{team.name} (#{team.division.name}),"
      end

      if i > 0
        # strip off the last comma for display purposes
        audit_text.chop!
      end

      self.audit << audit_text
    else
      # this is an update

      if self.first_name_changed?
        changes_found = true
        audit_text << " First name changed from #{self.first_name_was} to #{self.first_name}."
      end

      if self.last_name_changed?
        changes_found = true
        audit_text << " Last name changed from #{self.last_name_was} to #{self.last_name}."
      end

      if self.phone_changed?
        unless self.phone == self.phone_was
          changes_found = true
          audit_text << " Phone changed from #{self.phone_was} to #{self.phone}."
        end
      end

      if self.email_changed?
        changes_found = true
        audit_text << " Email changed from #{self.email_was} to #{self.email}."
      end

      if self.amount_in_cents_changed?
        changes_found = true
        old_amount = "$%.2f" % (self.amount_in_cents_was / 100)
        new_amount = "$%.2f" % (self.amount_in_cents / 100)
        audit_text << " Amount changed from #{old_amount} to #{new_amount}."
      end

      if self.paid_changed?
        changes_found = true
        audit_text << " Paid changed from #{self.paid_was} to #{self.paid}."
      end

      # look through teams for changes
      i = 0
      self.teams.each do |team|
        i += 1
        if team.new_record?
          changes_found = true
          audit_text << " Team ##{i} (#{team.division.name}) added with name: #{team.name}."
        else
          if team.division_id_changed?
            changes_found = true
            old_division = Division.find(team.division_id_was)
            new_division = Division.find(team.division_id)
            audit_text << " Division for team ##{i} (#{team.name}) changed from #{old_division.name} to #{new_division.name}."
          end
          if team.name_changed?
            changes_found = true
            audit_text << " Team name for team ##{i} (#{team.division.name}) changed from #{team.name_was} to #{team.name}."
          end
        end
      end

      if changes_found
        self.audit << audit_text
      end
    end
  end
end
