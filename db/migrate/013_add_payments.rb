class AddPayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.references :participant_registration
      t.references :user
      t.integer :amount_in_cents
      t.string :type
      t.text :details
      t.timestamps
    end

    # keep track of what the registration fee should be
    add_column :participant_registrations, :registration_fee, :integer, :default => 0

    # remove amount column because we don't need it anymore
    remove_column :participant_registrations, :amount_in_cents

    # remove paid columns since we really don't need them anymore
    remove_column :participant_registrations, :num_extra_group_photos_paid
    remove_column :participant_registrations, :num_dvd_paid
    remove_column :participant_registrations, :num_extra_small_shirts_paid
    remove_column :participant_registrations, :num_extra_medium_shirts_paid
    remove_column :participant_registrations, :num_extra_large_shirts_paid
    remove_column :participant_registrations, :num_extra_xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_2xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_3xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_4xlarge_shirts_paid
    remove_column :participant_registrations, :num_extra_5xlarge_shirts_paid
  end

  def self.down
    # drop our new payments table
    drop_table :payments

    # remove registration fee
    remove_column :participant_registrations, :registration_fee

    # add amount back in
    add_column :participant_registrations, :amount_in_cents, :integer, :default => 0

    # add extra paid columns back in
    add_column :participant_registrations, :num_extra_group_photos_paid, :integer
    add_column :participant_registrations, :num_dvd_paid, :integer
    add_column :participant_registrations, :num_extra_small_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_medium_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_large_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_2xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_3xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_4xlarge_shirts_paid, :integer
    add_column :participant_registrations, :num_extra_5xlarge_shirts_paid, :integer
  end
end