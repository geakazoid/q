class ModifyActions < ActiveRecord::Migration
  def self.up
    # add an original column so we can see the line comin from qview
    add_column :actions, :original, :string
  end

  def self.down
    # remove our new original field
    remove_column :actions, :original
  end
end