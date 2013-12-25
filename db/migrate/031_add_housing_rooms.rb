class AddHousingRooms < ActiveRecord::Migration
  def self.up
    # create new table to store housing rooms
    create_table :housing_rooms do |t|
      t.belongs_to :building
      t.string :number
      t.string :keycode, :default => ''
      t.timestamps
    end

    participants = ParticipantRegistration.all

    participants.each do |participant|
      housing_room = HousingRoom.find(:first, :conditions => "building_id = '#{participant.building_id}' and number = '#{participant.room}'")
      if housing_room.nil? and !participant.building.blank? and !participant.room.blank?
        housing_room = HousingRoom.new(:building => participant.building, :number => participant.room)
        housing_room.save
      end
    end
  end

  def self.down
    # drop our new housing_rooms table
    drop_table :housing_rooms
  end
end