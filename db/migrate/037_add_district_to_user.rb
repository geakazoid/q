class AddDistrictToUser < ActiveRecord::Migration
  def self.up
    # add district to user since we ask for it everywhere
    add_column :users, :district_id, :integer
  end

  def self.down
    # remove district_id from users table
    remove_column :users, :district_id
  end
end