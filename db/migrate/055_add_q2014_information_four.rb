class AddQ2014InformationFour < ActiveRecord::Migration
  def self.up
    # add additional participant_registration fields for Q2014
    add_column :participant_registrations, :num_district_teams, :int
    add_column :participant_registrations, :num_local_teams, :int

  end

  def self.down
    # remove additional participant_registration fields for Q2014
    remove_column :participant_registrations, :num_district_teams
    remove_column :participant_registrations, :num_local_teams
  end
end