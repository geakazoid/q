class Team < ActiveRecord::Base
  belongs_to :division
  belongs_to :team_registration
  has_and_belongs_to_many :participant_registrations
  belongs_to :coach, :class_name => "ParticipantRegistration", :foreign_key => 'coach_id'
  has_many :quizzers1, :class_name => "ParticipantRegistration", :foreign_key => "team1_id", :conditions => "registration_type = 'quizzer'"
  has_many :quizzers2, :class_name => "ParticipantRegistration", :foreign_key => "team2_id", :conditions => "registration_type = 'quizzer'"
  has_many :quizzers3, :class_name => "ParticipantRegistration", :foreign_key => "team3_id", :conditions => "registration_type = 'quizzer'"
  
  validates_presence_of :name
  validates_presence_of :division
  
  # custom validations
  validate do |team|
    team.errors.add_to_base("You cannot select more than seven quizzers per team.") if team.participant_registrations.size > 7
  end

  after_initialize :merge_teams

  HUMANIZED_ATTRIBUTES = {
    :name => "Team name"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def merge_teams
    @quizzer_list = quizzers1
    puts @quizzers.inspect
  end
  
  def quizzers
    @quizzer_list
  end

  def district_team?
    unless self.division.nil?
      self.division.name == 'District Experienced' or self.division.name == 'District Novice'
    else
      return false
    end
  end

  def local_team?
    unless self.division.nil?
      self.division.name == 'Local Experienced' or self.division.name == 'Local Novice'
    else
      return false
    end
  end

  def regional_team?
    unless self.division.nil?
      self.division.name == 'Field A' or self.division.name == 'Field B'
    else
      return false
    end
  end

  def novice_team?
    unless self.division.nil?
      self.division.name == 'District Novice' or self.division.name == 'Local Novice'
    else
      return false
    end
  end

  def experienced_team?
    unless self.division.nil?
      self.division.name == 'District Experienced' or self.division.name == 'Local Experienced'
    else
      return false
    end
  end

  def name_with_division
    self.division.name + ' - ' + self.name
  end
end
