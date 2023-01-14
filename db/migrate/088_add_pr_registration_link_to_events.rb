class AddPrRegistrationLinkToEvents < ActiveRecord::Migration
  def self.up
    # add field to events
    add_column :events, :participant_registration_link, :string
  end

  def self.down
    # remove field from events
    remove_column :events, :participant_registration_link
  end
end