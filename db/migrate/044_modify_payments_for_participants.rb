class ModifyPaymentsForParticipants < ActiveRecord::Migration
  def self.up  
    # add new columns
    #add_column :participant_registrations, :payment_id, :int
    #add_column :team_registrations, :payment_id, :int
#    
    #Payment.all.each do |payment|
    #  unless payment.team_registration_id.nil?
    #    team_registration = TeamRegistration.find(payment.team_registration_id)
    #    team_registration.payment_id = payment.id
    #    team_registration.save(false)
    #  end
    #end
#    
    #remove_column :payments, :team_registration_id
    
    add_column :payments, :participant_registration_id, :int
    add_column :payments, :details, :text
  end

  def self.down
    # # add columns back in
    # add_column :payments, :team_registration_id, :int
# 
    # TeamRegistration.all.each do |team_registration|
      # unless team_registration.payment_id.nil?
        # payment = Payment.find(team_registration.payment_id)
        # payment.team_registration_id = team_registration.id
        # payment.save(false)
      # end
    # end
# 
    # # remove our new columns
    # remove_column :team_registrations, :payment_id
    # remove_column :participant_registrations, :payment_id
    
    remove_column :payments, :participant_registration_id
    remove_column :payments, :details
  end
end