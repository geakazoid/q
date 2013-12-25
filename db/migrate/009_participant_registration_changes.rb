class ParticipantRegistrationChanges < ActiveRecord::Migration
  def self.up
    # remove unneeded columns
    remove_column :participant_registrations, :airline_arrival_date
    remove_column :participant_registrations, :airline_arrival_info
    remove_column :participant_registrations, :airline_departure_info
    remove_column :participant_registrations, :airline_departure_date

    # add new columns
    add_column :participant_registrations, :travel_type, :string
    add_column :participant_registrations, :arrival_airline, :string
    add_column :participant_registrations, :airline_arrival_date, :string
    add_column :participant_registrations, :airline_arrival_time, :string
    add_column :participant_registrations, :airline_arrival_from, :string
    add_column :participant_registrations, :need_arrival_shuttle, :boolean, :default => false
    add_column :participant_registrations, :departure_airline, :string
    add_column :participant_registrations, :airline_departure_date, :string
    add_column :participant_registrations, :airline_departure_time, :string
    add_column :participant_registrations, :need_departure_shuttle, :boolean, :default => false
    add_column :participant_registrations, :driving_arrival_date, :string
    add_column :participant_registrations, :driving_arrival_time, :string
    add_column :participant_registrations, :registration_code, :string
    add_column :participant_registrations, :num_extra_group_photos, :integer
    add_column :participant_registrations, :num_extra_group_photos_paid, :integer
    add_column :participant_registrations, :num_dvd, :integer
    add_column :participant_registrations, :num_dvd_paid, :integer
    add_column :participant_registrations, :housing_saturday, :boolean
    add_column :participant_registrations, :housing_sunday, :boolean
    add_column :participant_registrations, :breakfast_monday, :boolean
    add_column :participant_registrations, :lunch_monday, :boolean
    add_column :participant_registrations, :need_floorfan, :boolean
    add_column :participant_registrations, :need_pillow, :boolean
    add_column :participant_registrations, :num_extra_small_shirts, :integer
    add_column :participant_registrations, :num_extra_small_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_medium_shirts, :integer
    add_column :participant_registrations, :num_extra_medium_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_large_shirts, :integer
    add_column :participant_registrations, :num_extra_large_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_xlarge_shirts, :integer
    add_column :participant_registrations, :num_extra_xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_2xlarge_shirts, :integer
    add_column :participant_registrations, :num_extra_2xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_3xlarge_shirts, :integer
    add_column :participant_registrations, :num_extra_3xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_4xlarge_shirts, :integer
    add_column :participant_registrations, :num_extra_4xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_5xlarge_shirts, :integer
    add_column :participant_registrations, :num_extra_5xlarge_shirts_paid, :integer
    add_column :participant_registrations, :guardian, :string

    # switch show_to_others to be hide_from_others
    rename_column :participant_registrations, :show_to_others, :hide_from_others

    # loop through and flip all boolean values
    ParticipantRegistration.all.each do |pr|
      pr.hide_from_others = !pr.hide_from_others
      pr.save
    end
  end

  def self.down
    # drop new columns
    remove_column :participant_registrations, :travel_type
    remove_column :participant_registrations, :arrival_airline
    remove_column :participant_registrations, :airline_arrival_date
    remove_column :participant_registrations, :airline_arrival_time
    remove_column :participant_registrations, :airline_arrival_from
    remove_column :participant_registrations, :need_arrival_shuttle
    remove_column :participant_registrations, :departure_airline
    remove_column :participant_registrations, :airline_departure_date
    remove_column :participant_registrations, :airline_departure_time
    remove_column :participant_registrations, :need_departure_shuttle
    remove_column :participant_registrations, :driving_arrival_date
    remove_column :participant_registrations, :driving_arrival_time
    remove_column :participant_registrations, :registration_code
    remove_column :participant_registrations, :num_extra_group_photos
    remove_column :participant_registrations, :num_extra_group_photos_paid
    remove_column :participant_registrations, :num_dvd
    remove_column :participant_registrations, :num_dvd_paid
    remove_column :participant_registrations, :housing_saturday
    remove_column :participant_registrations, :housing_sunday
    remove_column :participant_registrations, :breakfast_monday
    remove_column :participant_registrations, :lunch_monday
    remove_column :participant_registrations, :need_floorfan
    remove_column :participant_registrations, :need_pillow
    remove_column :participant_registrations, :num_extra_small_shirts
    remove_column :participant_registrations, :num_extra_small_shirts_paid
    remove_column :participant_registrations, :num_extra_medium_shirts
    remove_column :participant_registrations, :num_extra_medium_shirts_paid
    remove_column :participant_registrations, :num_extra_large_shirts
    remove_column :participant_registrations, :num_extra_large_shirts_paid
    remove_column :participant_registrations, :num_extra_xlarge_shirts
    remove_column :participant_registrations, :num_extra_xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_2xlarge_shirts
    remove_column :participant_registrations, :num_extra_2xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_3xlarge_shirts
    remove_column :participant_registrations, :num_extra_3xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_4xlarge_shirts
    remove_column :participant_registrations, :num_extra_4xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_5xlarge_shirts
    remove_column :participant_registrations, :num_extra_5xlarge_shirts_paid
    remove_column :participant_registrations, :guardian

    # add old columns back in
    add_column :participant_registrations, :airline_arrival_date, :string
    add_column :participant_registrations, :airline_arrival_info, :string
    add_column :participant_registrations, :airline_departure_info, :string
    add_column :participant_registrations, :airline_departure_date, :string

    # switch hide_from_others to be show_to_others
    rename_column :participant_registrations, :hide_from_others, :show_to_others

    # loop through and flip all boolean values
    ParticipantRegistration.all.each do |pr|
      pr.show_to_others = !pr.show_to_others
      pr.save
    end
  end
end
