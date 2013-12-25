class FixFamilyDiscounts < ActiveRecord::Migration
  def self.up
    # keep track of which partitipant registrations provided the discount
    add_column :participant_registrations, :family_registrations, :string
  end

  def self.down
    # remove family_registrations
    remove_column :participant_registrations, :family_registrations
  end
end