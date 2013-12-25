class RegistrationItem < ActiveRecord::Base
  belongs_to :participant_registration
  belongs_to :registerable_item
end