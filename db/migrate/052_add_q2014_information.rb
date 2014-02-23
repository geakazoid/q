class AddQ2014Information < ActiveRecord::Migration
  def self.up
    # modify participant_registrations with new fields for Q2014
    add_column :participant_registrations, :confirmation_code, :string
    add_column :participant_registrations, :age, :integer
    add_column :participant_registrations, :understand_form_completion, :boolean
    add_column :participant_registrations, :over_18, :boolean
  end

  def self.down
    # remove new fields for Q2014
    remove_column :participant_registrations, :confirmation_code
    remove_column :participant_registrations, :age
    remove_column :participant_registrations, :understand_form_completion
    remove_column :participant_registrations, :over_18
  end
end