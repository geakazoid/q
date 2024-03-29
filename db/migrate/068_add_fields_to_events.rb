class AddFieldsToEvents < ActiveRecord::Migration
  def self.up
    # add fields to events
    add_column :events, :title, :string
    add_column :events, :logo_file_name,    :string
    add_column :events, :logo_content_type, :string
    add_column :events, :logo_file_size,    :integer
    add_column :events, :logo_updated_at,   :datetime
  end

  def self.down
    # remove fields from events
    remove_column :events, :title
    remove_column :events, :logo_file_name
    remove_column :events, :logo_content_type
    remove_column :events, :logo_file_size
    remove_column :events, :logo_updated_at
  end
end