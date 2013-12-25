class AddEvenMoreSeminars < ActiveRecord::Migration
  def self.up
    # modify seminar_registrations to add more seminars
    add_column :seminar_registrations, :seminar_15, :boolean
    add_column :seminar_registrations, :seminar_15_session, :string
    add_column :seminar_registrations, :seminar_16, :boolean
    add_column :seminar_registrations, :seminar_16_session, :string
  end

  def self.down
    # drop our new columns
    remove_column :seminar_registrations, :seminar_15
    remove_column :seminar_registrations, :seminar_15_session
    remove_column :seminar_registrations, :seminar_16
    remove_column :seminar_registrations, :seminar_16_session
  end
end