class ModifyBuildings < ActiveRecord::Migration
  def self.up
    # add in air conditioned column
    add_column :buildings, :air_conditioned, :boolean, :default => false

    # modify certain buildings to be air conditioned
    building_names = ['Cyprus','Rosewood','Spruce','Redwood']

    building_names.each do |name|
      building = Building.find_by_name(name)
      building.air_conditioned = true
      building.save
    end
  end

  def self.down
    # delete new air conditioned column
    remove_column :buildings, :air_conditioned
  end
end