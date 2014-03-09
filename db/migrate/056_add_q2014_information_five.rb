class AddQ2014InformationFive < ActiveRecord::Migration
  def self.up
    # add additional participant_registration fields for Q2014
    add_column :participant_registrations, :amount_ordered, :integer
    add_column :participant_registrations, :amount_paid, :integer
    add_column :participant_registrations, :amount_due, :integer
  end

  def self.down
    # remove additional participant_registration fields for Q2014
    remove_column :participant_registrations, :amount_ordered
    remove_column :participant_registrations, :amount_paid
    remove_column :participant_registrations, :amount_due
  end
end