class AddMenusToPages < ActiveRecord::Migration
  def self.up
    # add support for menus
    add_column :pages, :parent_id, :int
    add_column :pages, :menu, :boolean
  end

  def self.down
    # remove support for menus
    remove_column :pages, :parent_id
    remove_column :pages, :menu
  end
end