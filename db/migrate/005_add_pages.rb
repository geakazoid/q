class AddPages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :label
      t.string :title
      t.string :link
      t.text :body
      t.boolean :published, :default => true
      t.boolean :show_on_menu, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end