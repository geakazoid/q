class AddStayingOffCampus < ActiveRecord::Migration
  def self.up
    # modify participant_registrations with new fields for Q2016
    add_column :participant_registrations, :staying_off_campus, :string
  end

  def self.down
    # remove new fields for Q2016
    remove_column :participant_registrations, :staying_off_campus
  end
end
