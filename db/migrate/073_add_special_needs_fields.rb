class AddSpecialNeedsFields < ActiveRecord::Migration
  def self.up
    # add special needs specific participant_registration fields for Q2018 
    add_column :participant_registrations, :special_needs_food_allergies, :boolean
    add_column :participant_registrations, :special_needs_handicap_accessible, :boolean
    add_column :participant_registrations, :special_needs_hearing_impaired, :boolean
    add_column :participant_registrations, :special_needs_vision_impaired, :boolean
    add_column :participant_registrations, :special_needs_other, :boolean
    add_column :participant_registrations, :special_needs_na, :boolean
  end

  def self.down
    # remove special needs specific participant_registration fields for Q2018
    remove_column :participant_registrations, :special_needs_food_allergies
    remove_column :participant_registrations, :special_needs_handicap_accessible
    remove_column :participant_registrations, :special_needs_hearing_impaired
    remove_column :participant_registrations, :special_needs_vision_impaired
    remove_column :participant_registrations, :special_needs_other
    remove_column :participant_registrations, :special_needs_na
  end
end