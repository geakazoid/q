class AddTeamRegistrations < ActiveRecord::Migration
  def self.up
    # create team_registrations table
    create_table :team_registrations, {:force => true} do |t|
      t.belongs_to :user
      t.belongs_to :district
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.integer :amount_in_cents
      t.boolean :paid, :default => false
      t.timestamps
    end
    
    # create teams table
    create_table :teams, {:force => true} do |t|
      t.belongs_to :team_registration
      t.belongs_to :division
      t.string :name
      t.timestamps
    end
  end

  def self.down
    # drop tables
    drop_table :team_registrations
    drop_table :teams
  end
end