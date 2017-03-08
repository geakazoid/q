class AddQ2016Information < ActiveRecord::Migration
  def self.up
    # modify participant_registrations with new fields for Q2016
    add_column :participant_registrations, :guest_first_name, :string
    add_column :participant_registrations, :guest_last_name, :string
    add_column :participant_registrations, :group_leader_email, :string
    add_column :participant_registrations, :num_novice_district_teams, :integer
    add_column :participant_registrations, :num_experienced_district_teams, :integer
    add_column :participant_registrations, :num_novice_local_teams, :integer
    add_column :participant_registrations, :num_experienced_local_teams, :integer
    add_column :participant_registrations, :linens, :boolean
    add_column :participant_registrations, :pillow, :boolean
    add_column :participant_registrations, :is_quizzer, :boolean
    add_column :participant_registrations, :is_coach, :boolean
    add_column :participant_registrations, :planning_on_coaching, :boolean
    add_column :participant_registrations, :planning_on_officiating, :boolean
    add_column :participant_registrations, :coaching_team, :boolean
    add_column :participant_registrations, :coaching_team_2, :boolean
  end

  def self.down
    # remove new fields for Q2016
    remove_column :participant_registrations, :guest_first_name
    remove_column :participant_registrations, :guest_last_name
    remove_column :participant_registrations, :group_leader_email
    remove_column :participant_registrations, :num_novice_district_teams
    remove_column :participant_registrations, :num_experienced_district_teams
    remove_column :participant_registrations, :num_novice_local_teams
    remove_column :participant_registrations, :num_experienced_local_teams
    remove_column :participant_registrations, :linens
    remove_column :participant_registrations, :pillow
    remove_column :participant_registrations, :is_quizzer
    remove_column :participant_registrations, :is_coach
    remove_column :participant_registrations, :planning_on_coaching
    remove_column :participant_registrations, :planning_on_officiating
    remove_column :participant_registrations, :coaching_team
    remove_column :participant_registrations, :coaching_team_2
  end
end