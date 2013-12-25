class EvenMoreParticipantRegistrationChanges < ActiveRecord::Migration
  def self.up
    # remove unneeded columns
    remove_column :participant_registrations, :school_contact
    remove_column :participant_registrations, :school_phone

    # add new columns
    add_column :participant_registrations, :arrival_flight_number, :string
    add_column :participant_registrations, :departure_flight_number, :string
  end

  def self.down
    # add new columns back in
    add_column :participant_registrations, :school_contact, :string
    add_column :participant_registrations, :school_phone, :string

    # remove new columns
    remove_column :participant_registrations, :arrival_flight_number
    remove_column :participant_registrations, :departure_flight_number
  end
end