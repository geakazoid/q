class UpdateRegistrationOptions < ActiveRecord::Migration
  def self.up
    # add event id to registration_options
    add_column :registration_options, :event_id, :integer, :after => :id
  end

  def self.down
    # remove our new column
    remove_column :registration_options, :event_id
  end
end