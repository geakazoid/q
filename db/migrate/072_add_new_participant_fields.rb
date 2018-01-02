class AddNewParticipantFields < ActiveRecord::Migration
  def self.up
    # add additional participant_registration fields for Q2018
    add_column :participant_registrations, :graduation_year, :string
    add_column :participant_registrations, :coach_name, :string
    add_column :participant_registrations, :roommate_notes, :text
    add_column :participant_registrations, :understand_background_check, :boolean
  end

  def self.down
    # remove additional participant_registration fields for Q2018
    remove_column :participant_registrations, :graduation_year
    remove_column :participant_registrations, :coach_name
    remove_column :participant_registrations, :roommate_notes
    remove_column :participant_registrations, :understand_background_check
  end
end