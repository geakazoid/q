class RegisterableItem < ActiveRecord::Base
  has_many :registration_items
end