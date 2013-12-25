class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  validates_presence_of :label
  validates_uniqueness_of :label
  
  def to_param
    "#{id}-#{title.parameterize}"
  end
end