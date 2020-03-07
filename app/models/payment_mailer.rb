class PaymentMailer < ActionMailer::Base

  # send out a new payment email
  def new(payment)
    @recipients = "#{payment.first_name} #{payment.last_name} <#{payment.email}>"
    @from = AppConfig.admin_email
    @subject = "Please pay the following amount."
    @sent_on = Time.now
    @body[:payment] = payment
  end

  # A simple way to short circuit the delivery of an email from within
  # deliver_* methods defined in ActionMailer::Base subclasses.
  def do_not_deliver!
    def self.deliver! ; false ; end
  end

end
