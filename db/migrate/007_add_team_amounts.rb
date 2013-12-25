class AddTeamAmounts < ActiveRecord::Migration
  def self.up
    add_column :teams, :amount_in_cents, :integer
    add_column :teams, :discounted, :boolean

    # update team prices
    # this does not deal with discounts!
    teams = Team.find(:all)

    teams.each do |team|
      team.amount_in_cents = team.division.price_in_cents
      team.discounted = 0 if team.division.name == "District Experienced"
      team.discounted = 0 if team.division.name == "District Novice"
      team.save
    end

  end

  def self.down
    remove_column :teams, :amount_in_cents
    remove_column :teams, :discounted
  end
end