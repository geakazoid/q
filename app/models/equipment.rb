class Equipment < ActiveRecord::Base
  belongs_to :equipment_registration
  belongs_to :room

  # serialize / unserialize details hash when saving / loading from the database
  serialize :details, Hash
  
  # default details
  DEFAULT_DETAILS = {:ib_type => false,
                     :number => '',
                     :brand => '',
                     :operating_system => false,
                     :parallel_port => false,
                     :quizmachine_version => '',
                     :meets_requirements => false,
                     :color => '',
                     :length => '',
                     :make => '',
                     :model => '',
                     :number_of_plugs => '',
                     :monitor_size => false,
                     :username => '',
                     :password => '',
                     :first => false,
                     :hide => false}

  # set up accessors for details hash
  DEFAULT_DETAILS.keys.each do |key|
    # return details value for the specified key
    define_method key do
      if self.details.nil?
        self.details = {}
      end

      if !self.details.key?(key)
        DEFAULT_DETAILS[key]
      else
        self.details[key]
      end
    end

    # return details boolean value for the specified key (only effective on boolean fields)
    define_method "#{key}?".to_sym do
      if self.details.nil?
        self.details = {}
      end

      if !self.details.key?(key)
        DEFAULT_DETAILS[key]
      else
        self.details[key] == "0" ? false : true
      end
    end

    # set details value for the specified key
    define_method "#{key}=".to_sym do |value|
      if details.nil?
        self.details = {}
      end
      self.details[key.to_s.sub("=","").to_sym] = value
    end
  end

  def formatted_equipment_type
    a = self.equipment_type.split('_')
    a.each {|x| x.capitalize! }
    a.join(' ')
  end
end