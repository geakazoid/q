class ModifyQuizzingRooms < ActiveRecord::Migration
  def self.up
    # Change name of Lakeholm H to Lakeholm 205
    room = Room.find_by_name('Lakeholm H')
    room.name = 'Lakeholm 205'
    room.save

    # drop all faculty rooms
    room = Room.find_by_name('Faculty 105')
    room.destroy
    room = Room.find_by_name('Faculty 203')
    room.destroy
    room = Room.find_by_name('Faculty 209')
    room.destroy
  end

  def self.down
    # Change name of Lakeholm H to Lakeholm 205
    room = Room.find_by_name('Lakeholm 205')
    room.name = 'Lakeholm H'
    room.save

    # add faculty rooms back in
    room = Room.new
    room.name = 'Faculty 105'
    room.save
    room = Room.new
    room.name = 'Faculty 203'
    room.save
    room = Room.new
    room.name = 'Faculty 209'
    room.save
  end
end