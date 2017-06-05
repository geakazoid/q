class AddTemporaryRegionalTeams < ActiveRecord::Migration
  def self.up
    # add fields to participant registrations
    add_column :participant_registrations, :team_division, :string
  end

  def self.down
    # remove fields from participant registrations
    remove_column :participant_registration, :team_division
  end
end