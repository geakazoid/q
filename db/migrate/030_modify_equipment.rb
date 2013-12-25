class ModifyEquipment < ActiveRecord::Migration
  def self.up
    # add in new columns to keep track of the state of equipment
    add_column :equipment, :status, :string
    add_column :equipment, :room_id, :integer

    # add in new equipment_admin role
    Role.create(:name => 'equipment_admin')
  end

  def self.down
    # remove our new columns
    remove_column :equipment, :status
    remove_column :equipment, :room_id
  end
end