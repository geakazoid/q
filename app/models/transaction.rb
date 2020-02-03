class Transaction < ActiveRecord::Base
    belongs_to :user
    belongs_to :participant_registration
    belongs_to :team_registration
    belongs_to :event
  end