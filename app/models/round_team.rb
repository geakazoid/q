class RoundTeam < ActiveRecord::Base
  belongs_to :round
  belongs_to :quiz_team
  belongs_to :division_team
end
