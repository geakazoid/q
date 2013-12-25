class EvaluationMailer < ActionMailer::Base

  # send out request for evaluation
  def new_evaluation(evaluation, user)
    @recipients = Array.new
    if AppConfig.test_mode
      @recipients << "#{user.fullname} <#{user.email}>"
      @body[:original_email] = "#{evaluation.sent_to_name} <#{evaluation.sent_to_email}>"
    else
      @recipients << "#{evaluation.sent_to_name} <#{evaluation.sent_to_email}>"
    end
    @from = 'Todd Olson <tolson27@gmail.com>'
    @subject = "[Q2012] Official Evaluation Request"
    @sent_on = Time.now
    @body[:evaluation] = evaluation
  end
  
  # send out complete evaluation to admins
  def complete_evaluation(evaluation, recipients, user)
    @recipients = Array.new
    if AppConfig.test_mode
      if !user.nil?
        @recipients << "#{user.fullname} <#{user.email}>"
        @body[:original_email] = recipients.join(', ')
      else
        do_not_deliver!
      end
    else
      @recipients = recipients
    end
    @from = AppConfig.admin_email
    @subject = "[Q2012] Completed Official Evaluation"
    @sent_on = Time.now
    @body[:evaluation] = evaluation
  end

  # A simple way to short circuit the delivery of an email from within
  # deliver_* methods defined in ActionMailer::Base subclasses.
  def do_not_deliver!
    def self.deliver! ; false ; end
  end
  
  protected
  
  # setup default email options
  def setup_admin_email(official)
    @recipients = Array.new
    @recipients << 'Jeremy Driscoll <jdriscoll@realnets.com>'
    do_not_deliver! if @recipients.empty?
    @from = AppConfig.admin_email
    @subject = "[Q2012] "
    @sent_on = Time.now
    @body[:official] = official
  end
end
