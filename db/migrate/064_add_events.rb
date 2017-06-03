class AddEvents < ActiveRecord::Migration
  def self.up
    # create an events table
    create_table :events do |t|
      t.string :name
      t.boolean :active, :default => false
      t.timestamps
    end
  end

  def self.down
    # drop our new table
    drop_table :events
  end
end