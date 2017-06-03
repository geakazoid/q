class PaymentMailer < ActionMailer::Base

  # send out a receipt email
  def receipt(payment,session)
    @recipients = "#{payment.first_name} #{payment.last_name} <#{payment.email}>"
    @from = AppConfig.admin_email
    @subject = "Thank You for your payment!"
    @sent_on = Time.now
    @body[:payment] = payment
    @body[:session] = session
  end

  # send out a zero receipt email
  def zero_receipt(payment,session)
    @recipients = "#{payment.first_name} #{payment.last_name} <#{payment.email}>"
    @from = AppConfig.admin_email
    @subject = "Thank You for your submission!"
    @sent_on = Time.now
    @body[:payment] = payment
    @body[:session] = session
  end

  # A simple way to short circuit the delivery of an email from within
  # deliver_* methods defined in ActionMailer::Base subclasses.
  def do_not_deliver!
    def self.deliver! ; false ; end
  end

end
