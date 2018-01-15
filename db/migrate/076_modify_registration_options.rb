class ModifyRegistrationOptions < ActiveRecord::Migration
  def self.up
    # add category field for grouping
    add_column :registration_options, :category, :text

    # update category to reflect correct information
    execute "UPDATE registration_options SET category = 'meal'"
    execute "UPDATE registration_options SET category = 'other' WHERE item NOT LIKE '%Dinner%' AND item NOT LIKE '%Lunch%' AND item NOT LIKE '%Breakfast%' AND item NOT LIKE '%Meals%'"
  end

  def self.down
    # remove category field for grouping
    remove_column :registration_options, :category, :text
  end
end