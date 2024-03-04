class AddAdditional2024RegistrationOptions < ActiveRecord::Migration
  def self.up
    # add additional 2024 options
    options = [["Decades Quizzing","0","2","other","10"]]
    options.each do |item|
      option = RegistrationOption.new
      option.item = item[0]
      option.price = item[1]
      option.sort = item[2]
      option.category = item[3]
      option.event_id = item[4]
      option.save
    end
    options = [["Airport Shuttle","0","3","other","10"]]
    options.each do |item|
      option = RegistrationOption.new
      option.item = item[0]
      option.price = item[1]
      option.sort = item[2]
      option.category = item[3]
      option.event_id = item[4]
      option.save
    end
    options = [["Linens","0","4","other","10"]]
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
    # remove 2024 options
    execute "DELETE FROM registration_options where event_id = 10"
  end
end