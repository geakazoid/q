class EventRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :event

  named_scope :by_active_or_admin, lambda { |event_id|
    { :conditions => ["event_id = ? or role_id = 1", event_id.to_s] }
  }
end