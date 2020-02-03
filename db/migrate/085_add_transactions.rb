class AddTransactions < ActiveRecord::Migration
  def self.up
    # create a transactions table to track payments taken on cvent (q2020)
    create_table :transactions do |t|
      t.belongs_to :user
      t.belongs_to :event
      t.belongs_to :participant_registration
      t.belongs_to :team_registration
      t.string :email
      t.integer :fee
      t.boolean :complete
      t.timestamps
    end
  end

  def self.down
    # drop our new transactions table
    drop_table :transactions
  end
end