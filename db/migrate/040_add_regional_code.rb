class AddRegionalCode < ActiveRecord::Migration
  def self.up
    # add new columns
    add_column :team_registrations, :regional_code, :string
  end

  def self.down
    # remove new columns
    remove_column :team_registrations, :regional_code
  end
end