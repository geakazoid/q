class AddAirportTransportation < ActiveRecord::Migration
  def self.up
    # add additional participant_registration fields for Q2014
    add_column :participant_registrations, :airport_transportation, :boolean
  end

  def self.down
    # remove additional participant_registration fields for Q2014
    remove_column :participant_registrations, :airport_transportation
  end
end