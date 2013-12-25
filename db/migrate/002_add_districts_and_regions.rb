class AddDistrictsAndRegions < ActiveRecord::Migration
  def self.up
    # create districts table
    create_table :districts, {:force => true} do |t|
      t.string :name, :default => ""
      t.string :director, :default => ""
      t.string :email, :default => ""
      t.string :phone, :default => ""
      t.string :mobile_phone, :default => ""
      t.belongs_to :region
    end
    
    # create regions table
    create_table :regions, {:force => true} do |t|
      t.string :name, :default => ""
      t.string :director, :default => ""
      t.string :email, :default => ""
      t.string :phone, :default => ""
      t.string :mobile_phone, :default => ""
    end
  end

  def self.down
    # drop tables
    drop_table :districts
    drop_table :regions
  end
end