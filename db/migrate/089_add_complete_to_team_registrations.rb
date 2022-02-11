class AddCompleteToTeamRegistrations < ActiveRecord::Migration
  def self.up
    # add field to team_registrations
    add_column :team_registrations, :complete, :boolean
  end

  def self.down
    # remove field from team_registrations
    remove_column :team_registrations, :complete
  end
end