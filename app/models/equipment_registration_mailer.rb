class EquipmentRegistrationMailer < ActionMailer::Base

  # notify admins of a new equipment registration
  def new_registration(equipment_registration, recipients, user)
    setup_email(equipment_registration, recipients, user)
    @subject << 'New equipment Registration'
  end

  # notify admins of a canceled equipment registration
  def cancel_registration(equipment_registration, recipients, user)
    setup_email(equipment_registration, recipients, user)
    @subject << 'Canceled equipment Registration'
  end

  # notify admins of an updated equipment registration
  def update_registration(equipment_registration, recipients, user)
    setup_email(equipment_registration, recipients, user)
    @subject << 'Updated equipment Registration'
  end

  # send registering user a confirmation
  def new_confirmation(equipment_registration, user)
    @recipients = Array.new
    if AppConfig.test_mode
      @recipients << "#{user.fullname} <#{user.email}>"
      @body[:original_email] = "#{user.fullname} <#{user.email}>"
    else
      @recipients << "#{user.fullname} <#{user.email}>"
    end
    @from = AppConfig.admin_email
    @subject = "[#{AppConfig.site_name}] New equipment Registration"
    @sent_on = Time.now
    @body[:equipment_registration] = equipment_registration
    @body[:user] = user
  end

  # send updating user a confirmation
  def update_confirmation(equipment_registration, user)
    @recipients = Array.new
    if AppConfig.test_mode
      @recipients << "#{user.fullname} <#{user.email}>"
      @body[:original_email] = "#{user.fullname} <#{user.email}>"
    else
      @recipients << "#{user.fullname} <#{user.email}>"
    end
    @from = AppConfig.admin_email
    @subject = "[#{AppConfig.site_name}] Updated equipment Registration"
    @sent_on = Time.now
    @body[:equipment_registration] = equipment_registration
    @body[:user] = user
  end

  # send canceling user a confirmation
  def cancel_confirmation(equipment_registration, user)
    @recipients = Array.new
    if AppConfig.test_mode
      @recipients << "#{user.fullname} <#{user.email}>"
      @body[:original_email] = "#{user.fullname} <#{user.email}>"
    else
      @recipients << "#{user.fullname} <#{user.email}>"
    end
    @from = AppConfig.admin_email
    @subject = "[#{AppConfig.site_name}] Canceled equipment Registration"
    @sent_on = Time.now
    @body[:equipment_registration] = equipment_registration
    @body[:user] = user
  end

  # A simple way to short circuit the delivery of an email from within
  # deliver_* methods defined in ActionMailer::Base subclasses.
  def do_not_deliver!
    def self.deliver! ; false ; end
  end
  
  protected
  
  def setup_email(equipment_registration, recipients, user)
    @recipients = Array.new
    if AppConfig.test_mode
      @recipients << "#{user.fullname} <#{user.email}>"
      @body[:original_email] = recipients.join(', ')
    else
      @recipients = recipients
    end
    do_not_deliver! if @recipients.empty?
    @from = AppConfig.admin_email
    @subject = "[#{AppConfig.site_name}] "
    @sent_on = Time.now
    @body[:equipment_registration] = equipment_registration
    @body[:user] = user
  end
end