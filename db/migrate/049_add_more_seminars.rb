class AddMoreSeminars < ActiveRecord::Migration
  def self.up
    # modify seminar_registrations to add more seminars
    add_column :seminar_registrations, :seminar_6, :boolean
    add_column :seminar_registrations, :seminar_6_session, :string
    add_column :seminar_registrations, :seminar_7, :boolean
    add_column :seminar_registrations, :seminar_7_session, :string
    add_column :seminar_registrations, :seminar_8, :boolean
    add_column :seminar_registrations, :seminar_8_session, :string
    add_column :seminar_registrations, :seminar_9, :boolean
    add_column :seminar_registrations, :seminar_9_session, :string
    add_column :seminar_registrations, :seminar_10, :boolean
    add_column :seminar_registrations, :seminar_10_session, :string
    add_column :seminar_registrations, :seminar_11, :boolean
    add_column :seminar_registrations, :seminar_11_session, :string
    add_column :seminar_registrations, :seminar_12, :boolean
    add_column :seminar_registrations, :seminar_12_session, :string
    add_column :seminar_registrations, :seminar_13, :boolean
    add_column :seminar_registrations, :seminar_13_session, :string
    add_column :seminar_registrations, :seminar_14, :boolean
    add_column :seminar_registrations, :seminar_14_session, :string
  end

  def self.down
    # drop our new columns
    remove_column :seminar_registrations, :seminar_6
    remove_column :seminar_registrations, :seminar_6_session
    remove_column :seminar_registrations, :seminar_7
    remove_column :seminar_registrations, :seminar_7_session
    remove_column :seminar_registrations, :seminar_8
    remove_column :seminar_registrations, :seminar_8_session
    remove_column :seminar_registrations, :seminar_9
    remove_column :seminar_registrations, :seminar_9_session
    remove_column :seminar_registrations, :seminar_10
    remove_column :seminar_registrations, :seminar_10_session
    remove_column :seminar_registrations, :seminar_11
    remove_column :seminar_registrations, :seminar_11_session
    remove_column :seminar_registrations, :seminar_12
    remove_column :seminar_registrations, :seminar_12_session
    remove_column :seminar_registrations, :seminar_13
    remove_column :seminar_registrations, :seminar_13_session
    remove_column :seminar_registrations, :seminar_14
    remove_column :seminar_registrations, :seminar_14_session
  end
end