class FixMinistryProjects < ActiveRecord::Migration
  def self.up

    # messy messy messy
    # rename certain ministry projects and add new ones
    to_remove = ['Beliner Park',
                 'Big Run Park',
                 'Brentnelle Park',
                 'Glenwood Park',
                 'Helsel Park',
                 'Holton Park',
                 'Marion Franklin Park',
                 'Salvation Army',
                 'The Harbor',
                 'Three Creeks Park',
                 'Westgate Park']
    to_rename = ['Knox County Head Start',
                 'Ronald McDonald House']
    to_add = ['On-site Project',
              'Knox County Head Start - Site 1',
              'Knox County Head Start - Site 2',
              'Ronald McDonald House (29th)',
              'Ronald McDonald House (30th)']

    # remove ministry projects
    to_remove.each do |name|
      ministry_project = MinistryProject.find_by_name(name)
      ministry_project.destroy
    end

    # rename ministry projects
    to_rename.each do |name|
      ministry_project = MinistryProject.find_by_name(name)
      ministry_project.name = name + ' (OLD)'
      ministry_project.save
    end

    # add new ministry projects
    to_add.each do |name|
      ministry_project = MinistryProject.new
      ministry_project.name = name
      ministry_project.save
    end
  end

  def self.down
    # let's be honest...this isn't really possible to reverse
    # a new migration script will be required...and a lot of planning
  end
end