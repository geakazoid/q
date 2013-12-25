class UserMailer < ActionMailer::Base
  include ActionController::UrlWriter
  def signup_notification(user)
    setup_email(user)
    @subject << 'Please activate your new account'
    @body[:url] = "http://#{user.site.host}/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject << 'Your account has been activated!'
    @body[:url] = "http://#{user.site.host}/login"
  end
  
  protected
  
  def setup_email(user)
    @recipients = "#{user.email}"
    @from = 'admin@' + user.site.host
    @subject = "[#{user.site.name}] "
    @sent_on = Time.now
    @body[:user] = user
  end
end
