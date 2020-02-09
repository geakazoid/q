class Add2020RegistrationOptions < ActiveRecord::Migration
  def self.up
    # add 2020 options
    options = [["Linens","10","1","other","4"],
               ["Decades Quizzing","5","2","other","4"]
    ]
    options.each do |item|
      option = RegistrationOption.new
      option.item = item[0]
      option.price = item[1]
      option.sort = item[2]
      option.category = item[3]
      option.event_id = item[4]
      option.save
    end

  end

  def self.down
    # remove 2020 options
    execute "DELETE FROM registration_options where event_id = 4"
  end
end