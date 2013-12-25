class MoreParticipantRegistrationChanges < ActiveRecord::Migration
  def self.up
    # remove unneeded columns
    remove_column :participant_registrations, :user_id

    # add new columns
    add_column :participant_registrations, :exhibitor_housing, :string
    add_column :participant_registrations, :participant_housing, :string
  end

  def self.down
    # drop new columns
    remove_column :participant_registrations, :exhibitor_housing
    remove_column :participant_registrations, :participant_housing

    # add old columns back in
    add_column :participant_registrations, :user_id, :integer
  end
end