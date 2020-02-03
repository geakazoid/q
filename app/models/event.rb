class Event < ActiveRecord::Base
  # relationships
  belongs_to :creator, :class_name => 'User'
  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  def self.active_event
    find(:first, :conditions => 'active = true')
  end

  def self.active_id
    self.active_event.id
  end

  def self.get_events
    events = Event.find(:all)
    events.each do |event|
      event.name = event.name + ' (active) ' if event.id == Event.active_event.id
    end
  end
end