class AddTeamRegistrationAudit < ActiveRecord::Migration
  def self.up
    add_column :team_registrations, :audit, :text
  end

  def self.down
    remove_column :team_registrations, :audit
  end
end