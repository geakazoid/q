class ModifyMinistryProjects < ActiveRecord::Migration
  def self.up
    ministry_project = MinistryProject.new
    ministry_project.name = 'Not Participating'
    ministry_project.save
  end

  def self.down
    # remove not participating ministry project
    MinistryProject.find_by_name('Not Participating').destroy
  end
end