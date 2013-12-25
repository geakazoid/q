class AddCountryToPayments < ActiveRecord::Migration
  def self.up
    # add new columns
    add_column :payments, :country, :string
  end

  def self.down
    # remove new columns
    remove_column :payments, :country
  end
end