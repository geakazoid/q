class Official < ActiveRecord::Base
  # relationships
  belongs_to :user
  belongs_to :district
  has_many :evaluations
  belongs_to :event
  belongs_to :creator, :class_name => 'User'

  # serialize / unserialize roles hash when saving / loading from the database
  serialize :roles

  # validations
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :email
  validates_presence_of :district

  # custom validations
  validate_on_create :validate_roles
  validate_on_update :validate_roles

  # validate that roles have been selected
  def validate_roles
    if self.roles.empty?
      self.errors.add(:roles, "must be selected")
    end
  end

  # display a list of roles for this official
  def list_roles
    list = ''
    self.roles.each do |role|
      list += "#{role}, "
    end
    list.chop!.chop! unless list.empty?
  end

  # initialize roles if this is a new object or no roles have been selected
  def after_initialize
    self.roles ||= Array.new
  end

  # return the full name of the official
  def full_name
    self.first_name + ' ' + self.last_name
  end
end