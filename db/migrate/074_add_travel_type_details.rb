class AddTravelTypeDetails < ActiveRecord::Migration
  def self.up
    # add travel type details field
    add_column :participant_registrations, :travel_type_details, :text
  end

  def self.down
    # remove travel type details field
    remove_column :participant_registrations, :travel_type_details
  end
end