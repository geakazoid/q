class AddCoachesToTeams < ActiveRecord::Migration
  def self.up
    # add coach to teams that links to a participant registration id
    add_column :teams, :coach_id, :int
  end

  def self.down
    # remove coach_id field
    remove_column :teams, :coach_id
  end
end
