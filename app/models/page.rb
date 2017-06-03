class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  belongs_to :event
  has_many :children, :class_name => "Page", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Page"
  validates_presence_of :label
  validates_uniqueness_of :label
  
  def to_param
    "#{id}-#{title.parameterize}"
  end
end