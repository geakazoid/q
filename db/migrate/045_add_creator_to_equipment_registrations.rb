class AddCreatorToEquipmentRegistrations < ActiveRecord::Migration
  def self.up  
    add_column :equipment_registrations, :creator_id, :int
  end

  def self.down
    remove_column :equipment_registrations, :creator_id
  end
end