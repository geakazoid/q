class AddSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.string :name
      t.boolean :paid, :default => false
      t.timestamps
    end

    add_column :participant_registrations, :school_id, :integer
    add_column :participant_registrations, :school_contact, :string
    add_column :participant_registrations, :school_phone, :string
    add_column :participant_registrations, :school_fax, :string

    schools = [
      'Eastern Nazarene College (ENC)',
      'MidAmerica Nazarene University (MNU)',
      'Mount Vernon Nazarene University (NNU)',
      'Northwest Nazarene University (NNU)',
      'Olivet Nazarene University (ONU)',
      'Point Loma Nazarene University (PLNU)',
      'Southern Nazarene University (SNU)',
      'Trevecca Nazarene University (TNU)',
      'Nazarene Bible College',
      'Nazarene Theological Seminary'
    ]

    schools.each do |school_name|
      School.create(:name => school_name)
    end
  end

  def self.down
    drop_table :schools

    remove_column :participant_registrations, :school_id
    remove_column :participant_registrations, :school_contact
    remove_column :participant_registrations, :school_phone
    remove_column :participant_registrations, :school_fax
  end
end

# default School model in case one doesn't exist yet (or it was deleted).
class School < ActiveRecord::Base
end