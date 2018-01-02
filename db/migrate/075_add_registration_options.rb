class AddRegistrationOptions < ActiveRecord::Migration
  def self.up
    # create a registration_options table
    create_table :registration_options do |t|
      t.string :item
      t.integer :price
      t.integer :sort
      t.timestamps
    end

    # add initial options
    options = [["Monday, June 25 Dinner","9","1"],
               ["Tuesday, June 26 Breakfast","7","2"],
               ["Tuesday, June 26 Lunch","8","3"],
               ["Tuesday, June 26 Dinner","9","4"],
               ["Tuesday All Day Meals","24","5"],
               ["Wednesday, June 27 Breakfast","7","6"],
               ["Wednesday, June 27 Lunch","8","7"],
               ["Wednesday, June 27 Dinner","9","8"],
               ["Wednesday All Day Meals","24","9"],
               ["Thursday, June 28 Breakfast","7","10"],
               ["Thursday, June 28 Lunch","8","11"],
               ["Thursday, June 28 Dinner","9","12"],
               ["Thursday All Day Meals","24","13"],
               ["Friday, June 29 Breakfast","7","14"],
               ["Friday, June 29 Lunch","8","15"],
               ["Friday, June 29 Dinner","9","16"],
               ["Friday All Day Meals","24","17"],
               ["Saturday, June 30 Breakfast","7","18"],
               ["Shuttle","15","19"],
               ["Decades Quizzing","5","20"],
               ["Off-Campus Housing Discount","-21","21"]
  ]
    options.each do |item|
      option = RegistrationOption.new
      option.item = item[0]
      option.price = item[1]
      option.sort = item[2]
      option.save
    end

    # create join between participant_registrations and registration_options
    create_table :participant_registrations_registration_options, {:force => true, :id => false} do |t|
      t.integer :participant_registration_id, :registration_option_id
    end
  end

  def self.down
    # drop our new tables
    drop_table :registration_options
    drop_table :participant_registrations_registration_options
  end
end