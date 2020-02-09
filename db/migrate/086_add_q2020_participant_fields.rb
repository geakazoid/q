class AddQ2020ParticipantFields < ActiveRecord::Migration
  def self.up
    # add specific participant_registration fields for Q2020 
    add_column :participant_registrations, :over_9, :boolean
    add_column :participant_registrations, :understand_refund_policy, :boolean
  end

  def self.down
    # remove specific participant_registration fields for Q2020
    remove_column :participant_registrations, :over_9
    remove_column :participant_registrations, :understand_refund_policy
  end
end