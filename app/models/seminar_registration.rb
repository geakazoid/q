class SeminarRegistration < ActiveRecord::Base
  belongs_to :user
  belongs_to :district

  # This is purposefully imperfect -- it's just a check for bogus input. See
  # http://www.regular-expressions.info/email.html
  RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
  #RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  MSG_EMAIL_BAD   = "should look like an email address."

  # validations
  validates_presence_of :district
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :email
  validates_length_of :phone, :is => 10, :message => 'must consist of 10 digits!'
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  # strip out extra characters in phone
  def before_validation
    self.phone = phone.gsub(/[^0-9]/, '')
  end

  # reformat phone
  def after_validation
    if self.phone.length == 10
      phone.insert(6, '-')
      phone.insert(3, '-')
    end
  end

  # provide full name of person registering
  def full_name
    first_name + ' ' + last_name
  end
end