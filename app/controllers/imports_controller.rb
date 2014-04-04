class ImportsController < ApplicationController
  require_role ['admin']
  
  # GET /imports
  # lists main import page
  def index
  end
  
  def upload_file
    upload = params['upload']
    name = upload['datafile'].original_filename
    directory = "public/imports"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
    
    first_row = true
    FasterCSV.foreach(path, :quote_char => '"', :col_sep => ',') do |row|
      if first_row
        first_row = false
        next
      end
      
      full_name = row[3]
      email_address = row[6]
      contact_type = row[8]
      home_phone = ''
      mobile_phone = row[16]
      home_address = row[12]
      home_city = row[13]
      home_state_prov = row[14]
      home_country_code = row[11]
      home_zipcode = row[15]
      confirmation_number = row[5]
      airline_name = row[27]
      arrival_date_and_time = row[26]
      special_needs = row[21]
      flight_arrival_date_and_time = row[28]
      arrival_flight_number = row[29]
      departure_flight_number = row[30]
      flight_departure_date_and_time = row[31]
      grade_completed = row[23]
      group_leader = row[18]
      travel_plan = row[25]
      understand_form_completion = row[19]
      special_needs_details = row[22]
      roommate_preference_1 = row[32]
      roommate_preference_2 = row[33]
      shirt_size = row[24]
      local_church = row[17]
      round_trip_airport_transportation = row[40]
      num_local_teams = row[38].to_i
      num_district_teams = row[39].to_i
      district_name = row[10]
      amount_ordered = row[44].to_i
      amount_paid = row[46].to_i
      amount_due = row[47].to_i
      gender = row[9]
      emergency_contact_name = row[34]
      emergency_contact_number = row[35]
      emergency_contact_relationship = row[36]
      saturday_early_housing = row[40]
      sunday_early_housing = row[41]
      
      pr = ParticipantRegistration.find_by_confirmation_number(confirmation_number)
      pr = ParticipantRegistration.new if pr.nil?
      name = full_name.split(/, /)
      pr.first_name = name[1]
      pr.last_name = name[0]
      pr.email = email_address
      pr.promotion_agree = nil
      pr.hide_from_others = nil
      pr.registration_type = contact_type
      pr.home_phone = home_phone
      pr.mobile_phone = mobile_phone
      pr.street = home_address
      pr.city = home_city
      pr.state = home_state_prov
      pr.zipcode = home_zipcode
      pr.country = home_country_code
      pr.confirmation_number = confirmation_number
      #pr.age = age
      pr.arrival_airline = airline_name
      pr.driving_arrival_date = arrival_date_and_time
      pr.special_needs = special_needs
      pr.airline_arrival_date = flight_arrival_date_and_time
      pr.arrival_flight_number = arrival_flight_number
      pr.airline_departure_date = flight_departure_date_and_time
      pr.departure_flight_number = departure_flight_number
      pr.most_recent_grade = grade_completed
      pr.group_leader_import = group_leader
      pr.travel_type = travel_plan
      pr.understand_form_completion = understand_form_completion
      pr.over_18
      pr.special_needs_details = special_needs_details
      pr.roommate_preference_1 = roommate_preference_1
      pr.roommate_preference_2 = roommate_preference_2
      pr.shirt_size = shirt_size
      pr.local_church = local_church
      pr.num_local_teams = num_local_teams
      pr.num_district_teams = num_district_teams
      district = District.find_by_name(district_name)
      pr.district = district unless district.nil?
      pr.amount_ordered = amount_ordered
      pr.amount_paid = amount_paid
      pr.amount_due = amount_due
      pr.gender = gender
      pr.housing_saturday = saturday_early_housing
      pr.housing_sunday = sunday_early_housing
      logger.debug(pr.inspect)
      logger.debug("VALID:" + pr.valid?.to_s)
      logger.debug(pr.errors.inspect)
      pr.save(false)
    end
    
    respond_to do |format|
      format.html {
        flash[:notice] = "File imported successfully."
        redirect_to(imports_path)
      }
    end
  end
end