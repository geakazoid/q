class HousingRoom < ActiveRecord::Base
  belongs_to :building

  named_scope :ordered_by_building_and_room, {
    :joins => "INNER JOIN buildings ON housing_rooms.building_id = buildings.id",
    :order => "buildings.name asc, number asc"
  }

  named_scope :by_building, lambda { |building_id|
    { :conditions => ["building_id = ?", building_id] }
  }

  named_scope :keycode_complete, {
    :conditions => "keycode != ''"
  }

  named_scope :keycode_incomplete, {
    :conditions => "keycode = ''"
  }
end