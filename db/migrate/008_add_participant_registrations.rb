class AddParticipantRegistrations < ActiveRecord::Migration
  def self.up
    # create participant registrations table
    create_table :participant_registrations do |t|
      t.references :user
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :promotion_agree
      t.boolean :show_to_others
      t.string :registration_type
      t.string :street
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :gender
      t.string :most_recent_grade
      t.string :home_phone
      t.string :mobile_phone
      t.integer :team1_id
      t.integer :team2_id
      t.integer :team3_id
      t.string :group_leader
      t.string :local_church
      t.references :district
      t.string :shirt_size
      t.string :roommate_preference_1
      t.string :roommate_preference_2
      t.string :food_allergies
      t.text :food_allergies_details
      t.string :special_needs
      t.text :special_needs_details
      t.string :airline_arrival_date
      t.string :airline_arrival_info
      t.string :airline_departure_date
      t.string :airline_departure_info
      t.string :past_events_attended
      t.boolean :reminder
      t.integer :reminder_days
      t.integer :amount_in_cents
      t.boolean :paid, :default => false
      t.text :audit
      t.timestamps
    end

    # create participant registration users table
    create_table :participant_registration_users do |t|
      t.references :participant_registration
      t.references :user
      t.boolean :owner, :default => false
      t.timestamps
    end

    # create participants table
    create_table :participants do |t|
      t.string :first_name
      t.string :last_name
      t.references :participant_registration
      t.timestamps
    end

    # create registerable items table
    create_table :registerable_items do |t|
      t.string :name
      t.string :description
      t.integer :price_in_cents
      t.timestamps
    end

    # create registration items table
    create_table :registration_items do |t|
      t.references :participant_registration
      t.references :registerable_item
      t.integer :count, :default => 0
      t.timestamps
    end

    # add a few registerable items
    registerable_item = RegisterableItem.new do |ri|
      ri.name = 'Extra Group Photos'
      ri.description = 'Extra Group Photos'
      ri.price = '10.00'
    end
    registerable_item.save

    registerable_item = RegisterableItem.new do |ri|
      ri.name = 'Airport Shuttle from MVNU to the airport'
      ri.description = 'Airport Shuttle from MVNU to the airport'
      ri.price = '1.00'
    end
    registerable_item.save

    # add registration text for participant registrations
    page = Page.new
    page.title = 'Register Participant Text'
    page.label = 'Register Participant Text'
    page.show_on_menu = false
    page.published = true
    page.body = "<p>Some stuff you should know...</p>"
    page.save

    # add thank you page text for participant registrations
    page = Page.new
    page.title = 'Participant Confirmation Text'
    page.label = 'Participant Confirmation Text'
    page.show_on_menu = false
    page.published = true
    page.body = "<p>Thanks for registering for Q!</p>"
    page.save
  end

  def self.down
    # drop tables
    drop_table :participant_registrations
    drop_table :participant_registration_users
    drop_table :participants
    drop_table :registerable_items
    drop_table :registration_items

    # deleted created pages
    page = Page.find_by_title('Participant Confirmation Text')
    page.destroy unless page.nil?
    page = Page.find_by_title('Register Participant Text')
    page.destroy unless page.nil?
  end
end