class RegistrationOption < ActiveRecord::Base
  has_and_belongs_to_many :participant_registrations
end