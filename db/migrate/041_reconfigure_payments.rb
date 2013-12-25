class ReconfigurePayments < ActiveRecord::Migration
  def self.up
    # drop payments table
    drop_table :payments
    
    # recreate it with new settings
    create_table :payments do |t|
      t.belongs_to :user
      t.belongs_to :team_registration
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :credit_card_number
      t.string :phone
      t.string :email
      t.integer :amount_in_cents
      t.text :response
      t.timestamps
    end
  end

  def self.down
    # drop our new payments table
    drop_table :payments
    
    # recreate our old payments table
    create_table :payments do |t|
      t.references :participant_registration
      t.references :user
      t.integer :amount_in_cents
      t.string :type
      t.text :details
      t.timestamps
    end
  end
end