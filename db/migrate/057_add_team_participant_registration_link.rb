class AddTeamParticipantRegistrationLink < ActiveRecord::Migration
  def self.up
    # create join between teams and participant registrations to denote quizzers on teams
    create_table :participant_registrations_teams, {:force => true, :id => false} do |t|
      t.integer :participant_registration_id, :team_id
    end
  end

  def self.down
    # remove join table between participant registrations and teams
    drop_table :particpant_registrations_teams
  end
end