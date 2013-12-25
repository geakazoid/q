class Building < ActiveRecord::Base
  has_many :participant_registrations
end