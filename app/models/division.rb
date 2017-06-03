class Division < ActiveRecord::Base
  has_many :teams, :order => 'name asc'
  belongs_to :event

  validates_presence_of :name
  validates_presence_of :price_in_cents
  
  def name_price
    self.name + ' - ' + self.price.to_s
  end
  
  # return the price in a pretty format
  def pretty_price
    "$%.2f" % (price_in_cents / 100)
  end

  # return the type of division
  def type
    return 'regional' if (self.name.downcase.include?('regional'))
    return 'district' if (self.name.downcase.include?('district'))
    return 'local' if (self.name.downcase.include?('local'))
    return 'none'
  end
end