class FixGroupLeaders < ActiveRecord::Migration
  def self.up
    # rename group_leader_import
    rename_column :participant_registrations, :group_leader_import, :group_leader_text

    # update column data
    execute "UPDATE participant_registrations SET group_leader_text = group_leader"
    execute "UPDATE participant_registrations SET group_leader = NULL"
  end

  def self.down
    # rename back
    rename_column :participant_registrations, :group_leader_text, :group_leader_import

    # update column data
    execute "UPDATE participant_registrations SET group_leader = group_leader_import"
    execute "UPDATE participant_registrations SET group_leader_import = NULL"
  end
end