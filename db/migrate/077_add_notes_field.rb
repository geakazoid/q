class AddNotesField < ActiveRecord::Migration
  def self.up
    # add category field for grouping
    add_column :participant_registrations, :notes, :text
  end

  def self.down
    # remove category field for grouping
    remove_column :participant_registrations, :notes
  end
end