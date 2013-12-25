class ModifySeminars < ActiveRecord::Migration
  def self.up
    # add in new seminar admin role
    Role.create(:name => 'seminar_admin')
  end

  def self.down
    # delete new seminar admin role
    Role.find_by_name('seminar_admin').destroy
  end
end