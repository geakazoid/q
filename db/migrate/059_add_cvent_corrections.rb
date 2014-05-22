class AddCventCorrections < ActiveRecord::Migration
  def self.up
    # create cvent_corrections table
    create_table :cvent_corrections, :id => false do |t|
      t.text :correction_list
    end
    
    # create default corrections list
    connection = ActiveRecord::Base.connection
    connection.execute("insert into cvent_corrections set correction_list = ''")
  end
  
  def self.down
    # drop our new cvent_corrections table
    drop_table :cvent_corrections
  end
end