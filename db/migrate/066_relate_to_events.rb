class RelateToEvents < ActiveRecord::Migration
  def self.up
    #add event_id to various tables
    add_column :buildings, :event_id, :int
    add_column :divisions, :event_id, :int
    add_column :equipment_registrations, :event_id, :int
    add_column :ministry_projects, :event_id, :int
    add_column :officials, :event_id, :int
    add_column :pages, :event_id, :int
    add_column :participant_registrations, :event_id, :int
    add_column :team_registrations, :event_id, :int
    add_column :rooms, :event_id, :int
  end

  def self.down
    # remove event_id from tables
    remove_column :buildings, :event_id
    remove_column :divisions, :event_id
    remove_column :equipment_registrations, :event_id
    remove_column :ministry_projects, :event_id
    remove_column :officials, :event_id
    remove_column :pages, :event_id
    remove_column :participant_registrations, :event_id
    remove_column :team_registrations, :event_id
    remove_column :rooms, :event_id
  end
end