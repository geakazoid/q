class AddSeminars < ActiveRecord::Migration
  def self.up
    # create an seminar registration table
    create_table :seminar_registrations do |t|
      t.belongs_to :user
      t.belongs_to :district
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.boolean :seminar_1
      t.string :seminar_1_session
      t.boolean :seminar_2
      t.string :seminar_2_session
      t.boolean :seminar_3
      t.string :seminar_3_session
      t.boolean :seminar_4
      t.string :seminar_4_session
      t.boolean :seminar_5
      t.string :seminar_5_session
      t.timestamps
    end

    # add seminar registration page text
    page = Page.new
    page.title = 'Seminar Registration Text'
    page.label = 'Seminar Registration Text'
    page.show_on_menu = false
    page.published = true
    page.body = "<p>Register for a seminar below!</p>"
    page.save
  end

  def self.down
    # drop our new tables
    drop_table :seminar_registrations

    # delete created seminar text page
    page = Page.find_by_title('Seminar Registration Text')
    page.destroy unless page.nil?
  end
end