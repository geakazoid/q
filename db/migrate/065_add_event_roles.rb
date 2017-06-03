class AddEventRoles < ActiveRecord::Migration
  def self.up
    # create an event_roles table
    create_table :event_roles do |t|
      t.belongs_to :user
      t.belongs_to :role
      t.belongs_to :event
      t.timestamps
    end
  end

  def self.down
    # drop our new table
    drop_table :event_roles
  end
end