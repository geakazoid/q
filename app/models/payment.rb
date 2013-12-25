require 'json'

class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :team_registration
  belongs_to :participant_registration

  attr_accessor :transaction_id
  
  serialize :details

  # email validation variables
  RE_EMAIL_NAME   = '[\w\.%\+\-]+'
  RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  MSG_EMAIL_BAD   = "should look like an email address."

  # validations
  # validates_presence_of :first_name
  # validates_presence_of :last_name
  # validates_presence_of :address
  # validates_presence_of :city
  # validates_presence_of :state
  # validates_presence_of :zipcode
  # validates_presence_of :country
  # validates_presence_of :phone
  # validates_presence_of :email
  # validates_length_of :phone, :is => 10, :message => 'must consist of 10 digits!'
  # validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  
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
  
  def transaction_time
    Time.now.in_time_zone('Central Time (US & Canada)').strftime('%m/%d/%Y %I:%M:%S %p')
  end

  def total_amount
    self.amount_in_cents / 100
  end
  
  def zero_amount?
    self.amount_in_cents == 0
  end
end