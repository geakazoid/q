class School < ActiveRecord::Base
  has_many :participant_registrations
end