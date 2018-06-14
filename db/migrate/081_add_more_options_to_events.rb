class AddMoreOptionsToEvents < ActiveRecord::Migration
  def self.up
    # add participant registration code to events
    add_column :events, :participant_code, :string
    # add boolean for allowing optional purchases
    add_column :events, :allow_optional_purchases, :boolean
  end

  def self.down
    # remove participant registration code from events
    remove_column :events, :participant_code
    # remove boolean for allowing optional purchases
    remove_column :events, :allow_optional_purchases
  end
end