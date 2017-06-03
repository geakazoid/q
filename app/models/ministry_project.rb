class MinistryProject < ActiveRecord::Base
  has_many :participant_registrations
  belongs_to :event
end