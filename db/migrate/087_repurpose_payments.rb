class RepurposePayments < ActiveRecord::Migration
  def self.up
    # drop payments table
    drop_table :payments
    
    # create new payments table
    create_table :payments do |t|
      t.string :identifier
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :fee
      t.text :description
      t.boolean :paid
      t.timestamps
    end

    # modify transactions table
    add_column :transactions, :payment_id, :integer, :after => :team_registration_id
  end

  def self.down
    # drop our new payments table
    drop_table :payments
    
    # recreate our old payments table
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
      t.striing :country
      t.integer :participant_registration_id
      t.text :details
      t.timestamps
    end

    # remove extra field from transactions table
    remove_column :transactions, :payment_id
  end
end