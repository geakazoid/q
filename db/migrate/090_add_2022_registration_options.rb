class Add2022RegistrationOptions < ActiveRecord::Migration
  def self.up
    # add 2022 options
    options = [["Decades Quizzing","0","1","other","6"],
               ["Sunday Night Housing - June 26","0","2","other","6"],
               ["Airport Shuttle","0","3","other","6"]
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
    # remove 2022 options
    execute "DELETE FROM registration_options where event_id = 6"
  end
end