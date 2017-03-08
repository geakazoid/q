class OfficialMailer < ActionMailer::Base

  # notify admins of a new official registration
  def new_registration(official, recipients, user)
    @recipients = Array.new
    if AppConfig.test_mode
      @recipients << "#{user.fullname} <#{user.email}>"
      @body[:original_email] = recipients.join(', ')
    else
      @recipients = recipients
    end
    do_not_deliver! if @recipients.empty?
    @subject = '[Q2016] New Official Registration'
    @from = AppConfig.admin_email
    @sent_on = Time.now
    @body[:official] = official
  end

  # send registering user a confirmation of official registration
  def new_confirmation(official, user)
    @recipients = Array.new
    if AppConfig.test_mode
      @recipients << "#{user.fullname} <#{user.email}>"
      @body[:original_email] = "#{user.fullname} <#{user.email}>"
    else
      @recipients << "#{user.fullname} <#{user.email}>"
    end
    
    @from = AppConfig.admin_email
    @subject = '[Q2016] Official Registration Confirmation'
    @sent_on = Time.now
    @body[:official] = official
    @body[:user] = user
  end

  # A simple way to short circuit the delivery of an email from within
  # deliver_* methods defined in ActionMailer::Base subclasses.
  def do_not_deliver!
    def self.deliver! ; false ; end
  end
end
