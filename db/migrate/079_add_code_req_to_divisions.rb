class AddCodeReqToDivisions < ActiveRecord::Migration
  def self.up
    # add code requirement field to divisions
    add_column :divisions, :code_required, :boolean
  end

  def self.down
    # remove code requirement field from divisions
    remove_column :divisions, :code_required
  end
end