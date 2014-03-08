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

      full_name = row[0]
      email_address = row[1]
      contact_type = row[2]
      home_phone = row[3]
      mobile_phone = row[4]
      home_address = row[5]
      home_city = row[6]
      home_state_prov = row[7]
      home_country_code = row[8]
      confirmation_number = row[9]
      age = row[10]
      airline_name = row[11]
      arrival_date_and_time = row[12]
      special_needs = row[13]
      flight_arrival_date_and_time = row[14]
      flight_number = row[15]
      grade_completed = row[16]
      grade_completed2 = row[17]
      group_leader = row[18]
      travel_plan = row[19]
      understand_form_completion = row[20]
      over_18 = row[21]
      special_needs_details = row[22]
      roommate_preference_1 = row[23]
      roommate_preference_2 = row[24]
      shirt_size = row[25]
      local_church = row[26]
      round_trip_airport_transportation = row[27]
      num_local_teams = row[28]
      num_district_teams = row[29]
      district_name = row[30]
      shirt_size2 = row[31]
      amount_ordered = row[32]
      amount_paid = row[33]
      amount_due = row[34]
      gender = row[35]
      
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
      #pr.zipcode = home_zipcode
      pr.country = home_country_code
      pr.confirmation_number = confirmation_number
      pr.age = age
      pr.arrival_airline = airline_name
      pr.driving_arrival_date = arrival_date_and_time
      pr.special_needs = special_needs
      pr.airline_arrival_date = flight_arrival_date_and_time
      pr.arrival_flight_number = flight_number
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
      #amount_order
      #amount_paid
      pr.registration_fee = amount_due * 100
      pr.gender = gender
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