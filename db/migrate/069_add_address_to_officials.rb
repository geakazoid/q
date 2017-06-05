class AddAddressToOfficials < ActiveRecord::Migration
  def self.up
    # add fields to officials
    add_column :officials, :address, :string
    add_column :officials, :city, :string
    add_column :officials, :state, :string
    add_column :officials, :zipcode, :string
  end

  def self.down
    # remove fields from officials
    remove_column :officials, :address
    remove_column :officials, :city
    remove_column :officials, :state
    remove_column :officials, :zipcode
  end
end