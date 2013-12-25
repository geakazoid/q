class AddDiscount < ActiveRecord::Migration
  def self.up
    # add discount fields to participant registrations
    add_column :participant_registrations, :discount_in_cents, :integer
    add_column :participant_registrations, :discount_description, :text
  end

  def self.down
    # remove discount fields from participant registrations
    remove_column :participant_registrations, :discount_in_cents
    remove_column :participant_registrations, :discount_description
  end
end