class ParticipantRegistrationMailer < ActionMailer::Base
  def registration_shared(owner,user)
    setup_email(user)
    @subject << 'Shared Registration'
    @body[:owner] = owner
  end

  protected

  def setup_email(user)
    @recipients = "#{user.email}"
    @from = AppConfig.admin_email
    @subject = "[#{AppConfig.site_name}] "
    @sent_on = Time.now
    @body[:user] = user
  end
end