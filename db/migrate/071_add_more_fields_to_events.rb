class AddMoreFieldsToEvents < ActiveRecord::Migration
  def self.up
    # add fields to events
    add_column :events, :enable_participant_registration, :boolean
    add_column :events, :enable_team_registration, :boolean
    add_column :events, :enable_equipment_registration, :boolean
  end

  def self.down
    # remove fields from events
    remove_column :events, :enable_participant_registration
    remove_column :events, :enable_team_registration
    remove_column :events, :enable_equipment_registration
  end
end