class ParticipantRegistrationUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :participant_registration
end