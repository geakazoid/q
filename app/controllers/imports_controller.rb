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
      
      first_name = row[0] ##
      last_name = row[1] ##
      guest_first_name = row[2] ##
      guest_last_name = row[3] ##
      email_address = row[5] ##
      cc_email_address = row[6] ##
      contact_type = row[19] ##
      mobile_phone = row[12] ##
      home_address = row[7] ##
      home_city = row[8] ##
      home_state_prov = row[9] ##
      home_zipcode = row[10] ##
      home_country_code = row[11] ##
      confirmation_number = row[18] ##
      arrival_airline_name = row[54] ##
      arrival_date_and_time = row[57] ##
      special_needs = row[46] ##
      flight_arrival_date_and_time = row[56] ##
      arrival_flight_number = row[55] ##
      departure_flight_number = row[60] ##
      flight_departure_date_and_time = row[61] ##
      grade_completed = row[37] ##
      group_leader = row[40] ##
      travel_plan = row[53] ##
      special_needs_details = row[47] ##
      roommate_preference_1 = row[48] ##
      roommate_preference_2 = row[49] ##
      shirt_size = row[16] ##
      local_church = row[38] ##
      pillow = row[31] ##
      round_trip_airport_transportation = row[32] ##
      num_experienced_local_teams = row[29].to_i ##
      num_novice_local_teams = row[30].to_i ##
      num_experienced_district_teams = row[25].to_i ##
      num_novice_district_teams = row[26].to_i ##
      wants_decades = row[27] ##
      linens = row[28] ##
      district_name = row[14] ##
      amount_ordered = row[20].to_i ##
      amount_paid = row[21].to_i ##
      amount_due = row[22].to_i ##
      gender = row[13] ##
      emergency_contact_name = row[50] ##
      emergency_contact_number = row[52] ##
      emergency_contact_relationship = row[51] ##
      saturday_early_housing = row[33] ##
      sunday_early_housing = row[34] ##
      liability_form_received = row[62] ##
      is_quizzer = row[38] ## 
      is_coach = row[39] ##
      planning_on_coaching = row[41] ##
      coaching_team = row[42] ##
      planning_on_officiating = row[43] ##
      coaching_team_2 = row[44] ##
      
      # departure airline (sigh cvent sigh)
      for i in 58..59
        departure_airline_name = row[i] if !row[i].nil? ##
      end
      
      # understand form submission (sigh cvent sigh)
      for i in 35..36
        understand_form_completion = row[i] if !row[i].nil? ##
      end
      
      # skip empty rows
      if first_name.nil?
        next
      end
      
      pr = ParticipantRegistration.find_by_confirmation_number(confirmation_number)
      pr = ParticipantRegistration.new if pr.nil?
      pr.first_name = first_name
      pr.last_name = last_name
      pr.guest_first_name = guest_first_name
      pr.guest_last_name = guest_last_name
      pr.email = email_address
      pr.promotion_agree = nil
      pr.hide_from_others = nil
      pr.registration_type = contact_type
      pr.home_phone = ''
      pr.mobile_phone = mobile_phone
      pr.street = home_address
      pr.city = home_city
      pr.state = home_state_prov
      pr.zipcode = home_zipcode
      pr.country = home_country_code
      pr.confirmation_number = confirmation_number
      #pr.age = age
      pr.arrival_airline = arrival_airline_name
      pr.departure_airline = departure_airline_name
      pr.driving_arrival_date = arrival_date_and_time
      pr.special_needs = special_needs
      pr.airline_arrival_date = flight_arrival_date_and_time
      pr.arrival_flight_number = arrival_flight_number
      pr.airline_departure_date = flight_departure_date_and_time
      pr.departure_flight_number = departure_flight_number
      pr.most_recent_grade = grade_completed
      pr.group_leader_import = group_leader
      pr.group_leader_email = cc_email_address
      pr.travel_type = travel_plan
      pr.understand_form_completion = understand_form_completion
      pr.over_18
      pr.special_needs_details = special_needs_details
      pr.roommate_preference_1 = roommate_preference_1
      pr.roommate_preference_2 = roommate_preference_2
      pr.shirt_size = shirt_size
      pr.local_church = local_church
      pr.airport_transportation = round_trip_airport_transportation
      pr.num_novice_local_teams = num_novice_local_teams
      pr.num_experienced_local_teams = num_experienced_local_teams
      pr.num_novice_district_teams = num_novice_district_teams
      pr.num_experienced_district_teams = num_experienced_district_teams
      district = District.find_by_name(district_name)
      pr.district = district unless district.nil?
      pr.amount_ordered = amount_ordered
      pr.amount_paid = amount_paid
      pr.amount_due = amount_due
      pr.gender = gender
      pr.linens = linens
      pr.pillow = pillow
      pr.housing_saturday = saturday_early_housing
      pr.housing_sunday = sunday_early_housing
      pr.medical_liability = true if liability_form_received == "Yes"
      pr.is_quizzer = is_quizzer
      pr.is_coach = is_coach
      pr.coaching_team = coaching_team
      pr.coaching_team_2 = coaching_team_2
      pr.save(false)
      
      # try to automatically link this registration to a user based on email
      unless pr.nil? or pr.email.nil?
        #user = User.where("lower(email) = ?", pr.email.downcase).first
        user = User.find(:first, :conditions => "lower(email) = '#{pr.email.downcase}'")
        unless user.nil?
          participant_registration_user = ParticipantRegistrationUser.find(:first, :conditions => "user_id = #{user.id} and participant_registration_id = #{pr.id}")
          if participant_registration_user.nil?
            participant_registration_user = ParticipantRegistrationUser.new
            participant_registration_user.user = user
            participant_registration_user.participant_registration = pr
            participant_registration_user.owner = true
            participant_registration_user.save
          end
        end
      end
    end
    
    # apply corrections
    # connection = ActiveRecord::Base.connection
    #     result = connection.select_all("select correction_list from cvent_corrections limit 1")
    #     list = result[0]['correction_list'].split(/\r\n/)
    #     
    #     list.each do |line|
    #       correction = line.split(/,/)
    #       3.times do |i|
    #         correction[i].strip! unless correction[i].blank?
    #       end
    #       
    #       pr = ParticipantRegistration.find_by_confirmation_number(correction[0])
    #       pr.send("#{correction[1]}=".to_sym, correction[2])
    #       pr.save(false)
    # end
    
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
