class AddOfficials < ActiveRecord::Migration
  def self.up
    # create an officials table
    create_table :officials do |t|
      t.belongs_to :user
      t.integer :creator_id
      t.belongs_to :district
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.text :roles
      t.timestamps
    end
    
    # add in new official_admin role
    Role.create(:name => 'official_admin')
    
    # add official registration text page
    page = Page.new
    page.title = 'Register Officials Text'
    page.label = 'Register Officials Text'
    page.show_on_menu = false
    page.published = true
    page.body = "<p>Use the following form to register as an official for Q2012!</p>"
    page.save
  end

  def self.down
    # drop our new tables
    drop_table :officials
    
    # delete created official registration text page
    page = Page.find_by_title('Register Officials Text')
    page.destroy unless page.nil?
  end
end