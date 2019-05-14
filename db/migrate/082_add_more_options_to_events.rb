class AddShortFormOptionToEvents < ActiveRecord::Migration
  def self.up
    # add short participant registration form option to events
    add_column :events, :use_short_registration, :boolean
  end

  def self.down
    # remove short participant registration form option from events
    remove_column :events, :use_short_registration
  end
end