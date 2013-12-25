class AddMoreShirts < ActiveRecord::Migration
  def self.up
    # add new shirt sizes
    add_column :participant_registrations, :num_extra_youth_small_shirts, :integer
    add_column :participant_registrations, :num_extra_youth_medium_shirts, :integer
    add_column :participant_registrations, :num_extra_youth_large_shirts, :integer
  end

  def self.down
    # drop new shirt sizes
    remove_column :participant_registrations, :num_extra_youth_small_shirts
    remove_column :participant_registrations, :num_extra_youth_medium_shirts
    remove_column :participant_registrations, :num_extra_youth_large_shirts
  end
end