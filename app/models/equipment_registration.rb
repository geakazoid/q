class EquipmentRegistration < ActiveRecord::Base
  belongs_to :user
  belongs_to :district
  belongs_to :creator, :class_name => 'User'
  belongs_to :event
  has_many :equipment, :dependent => :destroy
  has_many :laptops, :class_name => 'Equipment', :conditions => 'equipment_type = "laptop"'
  has_many :interface_boxes, :class_name => 'Equipment', :conditions => 'equipment_type = "interface_box"'
  has_many :pads, :class_name => 'Equipment', :conditions => 'equipment_type = "string_of_pads"'
  has_many :monitors, :class_name => 'Equipment', :conditions => 'equipment_type = "monitor"'
  has_many :projectors, :class_name => 'Equipment', :conditions => 'equipment_type = "projector"'
  has_many :power_strips, :class_name => 'Equipment', :conditions => 'equipment_type = "power_strip"'
  has_many :extension_cords, :class_name => 'Equipment', :conditions => 'equipment_type = "extension_cord"'
  has_many :others, :class_name => 'Equipment', :conditions => 'equipment_type = "other"'
  has_many :recorders, :class_name => 'Equipment', :conditions => 'equipment_type = "recorder"'

  accepts_nested_attributes_for :equipment, :allow_destroy => true
  
  after_save :adjust_interface_boxes
  after_save :adjust_pads

  # This is purposefully imperfect -- it's just a check for bogus input. See
  # http://www.regular-expressions.info/email.html
  RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
  #RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  MSG_EMAIL_BAD   = "should look like an email address."

  # validations
  validates_presence_of :district
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :email
  validates_length_of :phone, :is => 10, :message => 'must consist of 10 digits!'
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

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

  # provide full name of person registering
  def full_name
    first_name + ' ' + last_name
  end

  # provide full name of person registering in format last name, first name
  def full_name_reversed
    last_name + ', ' + first_name
  end

  def full_list
    list = '<ul>'
    list += "<li>Laptops (" + self.laptops.count.to_s + ")</li>" unless self.laptops.count == 0
    list += "<li>Pads (" + self.pads.count.to_s + ")</li>" unless self.pads.count == 0
    list += "<li>Interface Boxes (" + self.interface_boxes.count.to_s + ")</li>" unless self.interface_boxes.count == 0
    list += "<li>Monitors (" + self.monitors.count.to_s + ")</li>" unless self.monitors.count == 0
    list += "<li>Projectors (" + self.projectors.count.to_s + ")</li>" unless self.projectors.count == 0
    list += "<li>Power Strips (" + self.power_strips.count.to_s + ")</li>" unless self.power_strips.count == 0
    list += "<li>Extension Cords (" + self.extension_cords.count.to_s + ")</li>" unless self.extension_cords.count == 0
    list += "<li>Microphones/Recorders (" + self.recorders.count.to_s + ")</li>" unless self.recorders.count == 0
    list += "<li>Other Items (" + self.others.count.to_s + ")</li>" unless self.others.count == 0
    list += '</ul>'
    return list
  end

  def adjust_interface_boxes
    current_usb_ib_count = current_parallel_ib_count = 0
    new_usb_ib_count = new_parallel_ib_count = 0
    self.equipment.each do |item|
      if item.equipment_type == 'interface_box'
        if item.ib_type == 'USB'
          current_usb_ib_count += 1
        end
        if item.ib_type == 'Parallel'
          current_parallel_ib_count += 1
        end
      end
      
      if item.equipment_type == 'interface_boxes'
        if item.ib_type == 'USB'
          new_usb_ib_count += item.number.to_i
        end
        if item.ib_type == 'Parallel'
          new_parallel_ib_count += item.number.to_i
        end
      end
    end

    if current_usb_ib_count < new_usb_ib_count
      # we need to add some usb boxes
      (new_usb_ib_count - current_usb_ib_count).times do
        equipment = Equipment.new(:equipment_registration_id => self.id, :equipment_type => 'interface_box', :ib_type => 'USB', :hide => true)
        equipment.save
      end
    end
    if current_usb_ib_count > new_usb_ib_count
      # we need to remove some usb boxes
      num_to_remove = current_usb_ib_count - new_usb_ib_count
      self.equipment.each do |item|
        if item.equipment_type == 'interface_box' and item.ib_type == 'USB' and num_to_remove > 0
          item.destroy
          num_to_remove -= 1
        end
      end
    end
    if current_parallel_ib_count < new_parallel_ib_count
      # we need to add some parallel boxes
      (new_parallel_ib_count - current_parallel_ib_count).times do
        equipment = Equipment.new(:equipment_registration_id => self.id, :equipment_type => 'interface_box', :ib_type => 'Parallel', :hide => true)
        equipment.save
      end
    end
    if current_parallel_ib_count > new_usb_ib_count
      # we need to remove some parallel boxes
      num_to_remove = current_parallel_ib_count - new_parallel_ib_count
      self.equipment.each do |item|
        if item.equipment_type == 'interface_box' and item.ib_type == 'Parallel' and num_to_remove > 0
          item.destroy
          num_to_remove -= 1
        end
      end
    end
  end

  def adjust_pads
    colors = ['red','yellow','green','blue','other']
    current_count = {'red' => 0, 'yellow' => 0, 'green' => 0, 'blue' => 0, 'other' => 0}
    new_count = {'red' => 0, 'yellow' => 0, 'green' => 0, 'blue' => 0, 'other' => 0}
    self.equipment.each do |item|
      if item.equipment_type == 'string_of_pads'
        colors.each do |color|
          if item.color == color.capitalize
            current_count[color] += 1
          end
        end
      end

      if item.equipment_type == 'pads'
        colors.each do |color|
          if item.color == color.capitalize
            new_count[color] += item.number.to_i
          end
        end
      end
    end

    colors.each do |color|
      if current_count[color] < new_count[color]
        # we need to add some strings
        (new_count[color] - current_count[color]).times do
          equipment = Equipment.new(:equipment_registration_id => self.id, :equipment_type => 'string_of_pads', :color => color.capitalize, :hide => true)
          equipment.save
        end
      end
      if current_count[color] > new_count[color]
        # we need to remove some strings
        num_to_remove = current_count[color] - new_count[color]
        self.equipment.each do |item|
          if item.equipment_type == 'string_of_pads' and item.color == color.capitalize and num_to_remove > 0
            item.destroy
            num_to_remove -= 1
          end
        end
      end
    end
  end

  # create a backup of all information for use in the updated official registration email
  def backup
    @backup = Hash.new
    @backup['full_name'] = self.full_name
    @backup['phone'] = self.phone
    @backup['email'] = self.email
    @backup['district'] = self.district.display_with_region
    @backup['laptops'] = self.laptops.count
    @backup['pads'] = self.pads.count
    @backup['interface_boxes'] = self.interface_boxes.count
    @backup['monitors'] = self.monitors.count
    @backup['projectors'] = self.projectors.count
    @backup['power_strips'] = self.power_strips.count
    @backup['extension_cords'] = self.extension_cords.count
    @backup['recorders'] = self.recorders.count
    @backup['others'] = self.others.count
  end

  # retrieve old information
  def old(key)
    @backup[key]
  end
end
