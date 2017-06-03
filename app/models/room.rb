class Room < ActiveRecord::Base
  has_many :equipment
  belongs_to :event
end