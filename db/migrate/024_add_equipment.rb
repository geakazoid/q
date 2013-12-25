class AddEquipment < ActiveRecord::Migration
  def self.up
    # create an equipment registration table
    create_table :equipment_registrations do |t|
      t.belongs_to :user
      t.belongs_to :district
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.timestamps
    end

    # create an equipment table
    create_table :equipment do |t|
      t.string :equipment_type
      t.belongs_to :equipment_registration
      #t.string :operating_system
      #t.string :ib_type
      t.text :details
      t.timestamps
    end

    # add equipment page text
    page = Page.new
    page.title = 'Equipment Registration Text'
    page.label = 'Equipment Registration Text'
    page.show_on_menu = false
    page.published = true
    page.body = "<p>Register your equipment below!</p>"
    page.save
  end

  def self.down
    # drop our new tables
    drop_table :equipment_registrations
    drop_table :equipment

    # delete created equipment text page
    page = Page.find_by_title('Equipment Registration Text')
    page.destroy unless page.nil?
  end
end