class Region < ActiveRecord::Base
  has_many :districts
  has_many :team_registrations, :through => :districts

  # return the number of district teams registered for this district
  def num_regional_teams
    num_teams = 0
    regional_division = Division.find_by_name('Regional Teams')
    self.team_registrations.each do |team_registration|
      team_registration.teams.each do |team|
        if team.division == regional_division and team.team_registration.complete?
          num_teams += 1
        end
      end
    end
    num_teams
  end
end