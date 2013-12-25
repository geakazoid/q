class AddNazsafe < ActiveRecord::Migration
  def self.up
    # modify participant registrations to support nazsafe
    add_column :participant_registrations, :nazsafe, :boolean, :default => false
  end

  def self.down
    # remove new columns in participant registrations
    remove_column :participant_registrations, :nazsafe
  end
end