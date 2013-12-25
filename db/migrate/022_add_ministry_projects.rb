class AddMinistryProjects < ActiveRecord::Migration
  def self.up
    create_table :ministry_projects do |t|
      t.string :name
      t.timestamps
    end

    # add buildings to our new table
    ministry_projects = ['Anheuser-Busch Sports Park','Antrim Park','Beliner Park','Big Run Park','Big Walnut Park','Brandy Pond - Three Creeks','Brentnelle Park','Crisis Kits','Glenwood Park','Helsel Park','Heron Pond - Three Creeks','Holton Park','Indian Mound','Innis Park','Knox County Head Start','Lower Lights Ministry','Marion Franklin Park','Nafzger Park','Rhoads Park','Ronald McDonald House','Salvation Army','Smith Farm - Three Creeks','Sycamore Fields - Three Creeks','The Harbor','Three Creeks - Three Creeks','Three Creeks Park','Tuttle Park','Westgate Park','Whetstone Park of Roses']
    ministry_projects.each do |name|
      ministry_project = MinistryProject.new
      ministry_project.name = name
      ministry_project.save
    end

    # modify participant registrations to support ministry projects
    add_column :participant_registrations, :ministry_project_id, :integer
    add_column :participant_registrations, :ministry_project_group, :string

    # add in new ministry project admin role
    Role.create(:name => 'ministry_project_admin')
  end

  def self.down
    # drop our new buildings table
    drop_table :ministry_projects

    # remove new columns in participant registrations
    remove_column :participant_registrations, :ministry_project_id
    remove_column :participant_registrations, :ministry_project_group
  end
end