class ImportsController < ApplicationController
  require_role ['admin']
  
  # GET /imports
  # lists main import page
  def index
  end
  
  # POST /imports/upload_file
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
      flight_arrival_date_and_time = row[29]
      arrival_flight_number = row[28]
      departure_flight_number = row[36]
      flight_departure_date_and_time = row[37]
      grade_completed = row[23]
      group_leader = row[18]
      travel_plan = row[25]
      understand_form_completion = row[19]
      special_needs_details = row[22]
      roommate_preference_1 = row[38]
      roommate_preference_2 = row[39]
      shirt_size = row[24]
      local_church = row[17]
      round_trip_airport_transportation = row[46]
      num_local_teams = row[44].to_i
      num_district_teams = row[45].to_i
      district_name = row[10]
      amount_ordered = row[50].to_i
      amount_paid = row[52].to_i
      amount_due = row[53].to_i
      gender = row[9]
      emergency_contact_name = row[40]
      emergency_contact_number = row[41]
      emergency_contact_relationship = row[42]
      saturday_early_housing = row[47]
      sunday_early_housing = row[48]
      liability_form_received = row[54]
      
      # departure airline (sigh cvent sigh)
      for i in 30..34
        departure_airline_name = row[i] if !row[i].nil?
      end
      
      # skip empty rows
      if full_name.nil?
        next
      end
      
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
      pr.departure_airline = departure_airline_name
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
      pr.airport_transportation = round_trip_airport_transportation
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
      pr.medical_liability = true if liability_form_received == "Yes"
      pr.save(false)
    end
    
    # apply corrections
    connection = ActiveRecord::Base.connection
    result = connection.select_all("select correction_list from cvent_corrections limit 1")
    list = result[0]['correction_list'].split(/\r\n/)
    
    list.each do |line|
      correction = line.split(/,/)
      3.times do |i|
        correction[i].strip! unless correction[i].blank?
      end
      
      pr = ParticipantRegistration.find_by_confirmation_number(correction[0])
      pr.send("#{correction[1]}=".to_sym, correction[2])
      pr.save(false)
    end
    
    respond_to do |format|
      format.html {
        flash[:notice] = "File imported successfully."
        redirect_to(imports_path)
      }
    end
  end

  # GET /imports/corrections
  # lists import corrections page
  def corrections
    # make a db connections
    connection = ActiveRecord::Base.connection
  
    # update our corrections in the database
    if request.post?
      connection.execute("update cvent_corrections set correction_list = '" + params[:corrections_text] + "'")
      
      respond_to do |format|
        format.html {
          flash[:notice] = "Corrections updated."
          redirect_to(corrections_imports_path)
        }
      end
    end
    
    result = connection.select_all("select correction_list from cvent_corrections limit 1")
    @correction_list = result[0]['correction_list']
    
    #connection.close
  end
end