class AddQ2014InformationSix < ActiveRecord::Migration
  def self.up
    # add additional participant_registration fields for Q2014
    add_column :participant_registrations, :emergency_contact_name, :string
    add_column :participant_registrations, :emergency_contact_number, :string
    add_column :participant_registrations, :emergency_contact_relationship, :string
  end

  def self.down
    # remove additional participant_registration fields for Q2014
    remove_column :participant_registrations, :emergency_contact_name
    remove_column :participant_registrations, :emergency_contact_number
    remove_column :participant_registrations, :emergency_contact_relationship
  end
end