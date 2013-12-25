class AddAirportsToParticipants < ActiveRecord::Migration
  def self.up
    # add new columns
    add_column :participant_registrations, :arrival_airport, :string
    add_column :participant_registrations, :departure_airport, :string
  end

  def self.down
    # drop new columns
    remove_column :participant_registrations, :arrival_airport
    remove_column :participant_registrations, :departure_airport
  end
end
