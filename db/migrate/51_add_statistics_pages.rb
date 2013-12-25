class AddStatisticsPages < ActiveRecord::Migration
  def self.up
    # add a table to store statistics pages
    create_table :statistics do |t|
      t.string :name
      t.string :title
      t.text :body
      t.timestamps
    end
    
    # add default statistics pages
    Statistic.create(:name => 'ln')
    Statistic.create(:name => 'le1')
    Statistic.create(:name => 'le2')
    Statistic.create(:name => 'dn')
    Statistic.create(:name => 'de1')
    Statistic.create(:name => 'de2')
    Statistic.create(:name => 'ra')
    Statistic.create(:name => 'rb')
    Statistic.create(:name => 'ot')
    Statistic.create(:name => 'koh')
    Statistic.create(:name => 'jff')
    Statistic.create(:name => 'td')
  end

  def self.down
    # drop our new statistics pages table
    drop_table :statistics
  end
end