class TransactionMailer < ActionMailer::Base

  # send out a receipt email
  def receipt(transaction,data)
    fullname = nil
    first_name = nil
    email = nil
    subject = nil

    if !transaction.payment.nil?
      # handle trransaction for a one off payment
      fullname = transaction.payment.first_name + ' ' + transaction.payment.last_name
      first_name = transaction.payment.first_name
      email = transaction.payment.email
      subject = "Thank you for your payment!"
    end

    if !transaction.participant_registration.nil? 
      # handle transaction for a participant registration
      fullname = transaction.user.fullname
      first_name = transaction.user.first_name
      email = transaction.user.email
      subject = "Thank you for your participant registration and payment!"
    end

    if !transaction.team_registration.nil? 
      # handle transaction for a team registration
      fullname = transaction.user.fullname
      first_name = transaction.user.first_name
      email = transaction.user.email
      subject = "Thank you for your team registration and payment!"
    end

    @recipients = "#{fullname} <#{email}>"
    @from = AppConfig.admin_email
    @subject = subject
    @sent_on = Time.now
    @body[:subject] = subject
    @body[:first_name] = first_name
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
