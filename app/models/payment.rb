class Payment < ActiveRecord::Base
    # validations
    validates_presence_of :first_name
    validates_presence_of :last_name
    validates_presence_of :email
    validates_presence_of :fee
    validates_numericality_of :fee, :only_integer => :true
    validates_presence_of :description
end