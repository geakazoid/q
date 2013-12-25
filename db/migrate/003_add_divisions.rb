class AddDivisions < ActiveRecord::Migration
  def self.up
    # create divisions table
    create_table :divisions, {:force => true} do |t|
      t.string :name
      t.integer :price_in_cents
    end
    
    # populate default divisions
    Division.create(:name => "District Experienced", :price_in_cents => 14000)
    Division.create(:name => "District Novice", :price_in_cents => 14000)
    Division.create(:name => "Local Experienced", :price_in_cents => 10000)
    Division.create(:name => "Local Novice", :price_in_cents => 10000)
    Division.create(:name => "Regional Teams", :price_in_cents => 30000)
  end

  def self.down
    # drop tables
    drop_table :divisions
  end
end