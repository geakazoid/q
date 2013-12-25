class AddPaperwork < ActiveRecord::Migration
  def self.up
    # modify participant registrations to support paperwork
    add_column :participant_registrations, :medical_liability, :boolean, :default => false
    add_column :participant_registrations, :background_check, :boolean, :default => false

    # add in new paperwork admin role
    Role.create(:name => 'paperwork_admin')
  end

  def self.down
    # remove new columns in participant registrations
    remove_column :participant_registrations, :medical_liability
    remove_column :participant_registrations, :background_check
  end
end