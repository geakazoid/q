class TransactionMailer < ActionMailer::Base

  # send out a receipt email
  def receipt(transaction,data)
    @recipients = "#{transaction.user.fullname} <#{transaction.user.email}>"
    @from = AppConfig.admin_email
    @subject = "Thank You for your registration and payment!"
    @sent_on = Time.now
    @body[:transaction] = transaction
    @body[:data] = data
  end

  # send out a zero receipt email
  def zero_receipt(transaction)
    @recipients = "#{transaction.user.fullname} <#{transaction.user.email}>"
    @from = AppConfig.admin_email
    @subject = "Thank You for your registration!"
    @sent_on = Time.now
    @body[:transaction] = transaction
  end

  # A simple way to short circuit the delivery of an email from within
  # deliver_* methods defined in ActionMailer::Base subclasses.
  def do_not_deliver!
    def self.deliver! ; false ; end
  end

end
