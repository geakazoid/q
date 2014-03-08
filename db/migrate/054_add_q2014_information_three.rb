class AddQ2014InformationThree < ActiveRecord::Migration
  def self.up
    # rename confirmation_code to be confirmation_number
    rename_column :participant_registrations, :confirmation_code, :confirmation_number

  end

  def self.down
    # rename confirmation_number back to be confirmation_code
    rename_column :participant_registrations, :confirmation_number, :confirmation_code
  end
end