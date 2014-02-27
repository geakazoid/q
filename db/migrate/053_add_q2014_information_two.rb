class AddQ2014InformationTwo < ActiveRecord::Migration
  def self.up
    # modify participant_registrations with new fields for Q2014
    add_column :participant_registrations, :group_leader_import, :string
  end

  def self.down
    # remove new fields for Q2014
    remove_column :participant_registrations, :group_leader_import
  end
end