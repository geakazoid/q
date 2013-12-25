class AddSoxTickets < ActiveRecord::Migration
  def self.up
    # modify participant registrations to support event tickets
    add_column :participant_registrations, :num_sox_tickets, :integer
    add_column :participant_registrations, :num_sv_tickets, :integer
    add_column :participant_registrations, :sox_transportation, :boolean
    add_column :participant_registrations, :sv_transportation, :boolean
  end

  def self.down
    # remove new columns in participant registrations
    remove_column :participant_registrations, :num_sox_tickets
    remove_column :participant_registrations, :num_sv_tickets
    remove_column :participant_registrations, :sox_transportation
    remove_column :participant_registrations, :sv_transportation
  end
end