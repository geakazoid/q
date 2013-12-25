class RemoveSoxTickets < ActiveRecord::Migration
  def self.up
    # remove new columns in participant registrations
    remove_column :participant_registrations, :num_sox_tickets
    remove_column :participant_registrations, :sox_transportation
  end

  def self.down
        # modify participant registrations to support event tickets
    add_column :participant_registrations, :num_sox_tickets, :integer
    add_column :participant_registrations, :sox_transportation, :boolean
  end
end