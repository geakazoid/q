class AddCountry < ActiveRecord::Migration
  def self.up
    # add country to participant registrations
    add_column :participant_registrations, :country, :string
  end

  def self.down
    # remove country from participant registrations
    remove_column :participant_registrations, :country
  end
end