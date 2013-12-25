class District < ActiveRecord::Base
  belongs_to :region
  has_many :users
  has_many :team_registrations
  has_many :teams, :through => :team_registrations

  # display the district name with it's corresponding region
  def display_with_region
    "#{name} / #{region.name}"
  end

  # return the number of district teams registered for this district
  def num_district_teams
    num_teams = 0
    novice_division = Division.find_by_name('District Novice')
    experienced_division = Division.find_by_name('District Experienced')
    teams.each do |team|
      if team.division == novice_division or team.division == experienced_division
        if team.team_registration.complete?
          num_teams += 1
        end
      end
    end
    num_teams
  end
end