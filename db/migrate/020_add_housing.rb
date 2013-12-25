class AddHousing < ActiveRecord::Migration
  def self.up
    create_table :buildings do |t|
      t.string :name
      t.timestamps
    end

    # add buildings to our new table
    buildings = ['Oakwood','Pioneer','Galloway','Maplewood','Elmwood','Rosewood','Cedar','Birch D','Cyprus','Redwood','Spruce','President\'s Guest House','Admissions Apartment','McBride North','McBride South']
    buildings.each do |name|
      building = Building.new
      building.name = name
      building.save
    end

    # modify participant registrations to support buildings
    add_column :participant_registrations, :building_id, :integer
    add_column :participant_registrations, :room, :string

    # add in new housing admin role
    Role.create(:name => 'housing_admin')
  end

  def self.down
    # drop our new buildings table
    drop_table :buildings

    # remove new columns in participant registrations
    remove_column :participant_registrations, :building_id
    remove_column :participant_registrations, :room
  end
end