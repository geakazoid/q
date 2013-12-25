class AddRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string :name
      t.timestamps
    end

    # add rooms to our new table
    rooms = ['Chapel 113',
      'Chapel 124',
      'Chapel 102',
      'Chapel 202',
      'Chapel 232',
      'Chapel 233',
      'Jenny K Moore 201',
      'Jenny K Moore 203',
      'Jenny K Moore 204',
      'Jenny K Moore 205',
      'Jenny K Moore 206',
      'Campus Center 228',
      'Campus Center 243',
      'Campus Center 300',
      'Campus Center 302',
      'Campus Center 306',
      'Regents 015',
      'Regents 016',
      'Regents 238',
      'Faculty 105',
      'Faculty 203',
      'Faculty 209',
      'Lakeholm WC',
      'Lakeholm Chapel',
      'Lakeholm Banquet',
      'Lakeholm 103',
      'Lakeholm 104',
      'Lakeholm 105',
      'Lakeholm 106',
      'Lakeholm A',
      'Lakeholm D',
      'Lakeholm E',
      'Lakeholm H',
      'Chapel Auditorium',
      'Central Complex SA',
      'Central Complex CG',
      'Jenny K Moore 109',
      'Jetter 106',
      'Jetter 133',
      'Jetter 143',
      'Quiz Office',
      'IT Office']

    rooms.each do |name|
      room = Room.new
      room.name = name
      room.save
    end
  end

  def self.down
    # drop our new rooms table
    drop_table :rooms
  end
end