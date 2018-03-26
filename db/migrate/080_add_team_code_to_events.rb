class AddTeamCodeToEvents < ActiveRecord::Migration
  def self.up
    # add team code to events
    add_column :events, :team_code, :string
  end

  def self.down
    # remove team code from events
    remove_column :events, :team_code
  end
end