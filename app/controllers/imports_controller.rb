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
      
      full_name = row[0] 
      last_name, first_name = full_name.split(",") unless full_name.nil?
      guest_type = row[1] ## #
      guest_name = row[2] ## #
      email_address = row[4] ##
      #cc_email_address = row[5] ##
      contact_type = row[18] ##
      mobile_phone = row[11] ##
      home_address = row[6] ##
      home_city = row[7] ##
      home_state_prov = row[8] ##
      home_zipcode = row[9] ##
      home_country_code = row[10] ##
      confirmation_number = row[17] ##
      arrival_airline_name = row[53] ##
      arrival_date_and_time = row[56] ##
      special_needs = row[45] ##
      flight_arrival_date_and_time = row[55] ##
      arrival_flight_number = row[54] ##
      departure_flight_number = row[59] ##
      flight_departure_date_and_time = row[60] ##
      grade_completed = row[36] ##
      group_leader = row[40] ##
      travel_plan = row[52] ##
      special_needs_details = row[46] ##
      roommate_preference_1 = row[47] ##
      roommate_preference_2 = row[48] ##
      shirt_size = row[15] ##
      local_church = row[37] ##
      pillow = row[30] ##
      round_trip_airport_transportation = row[31] ##
      num_experienced_local_teams = row[28].to_i ##
      num_novice_local_teams = row[29].to_i ##
      num_experienced_district_teams = row[24].to_i ##
      num_novice_district_teams = row[25].to_i ##
      wants_decades = row[26] ##
      linens = row[27] ##
      district_name = row[13] ##
      amount_ordered = row[19].delete(',').to_i if !row[19].nil? ##
      amount_paid = row[20].delete(',').to_i if !row[20].nil? ##
      amount_due = row[21].delete(',').to_i if !row[21].nil? ##
      gender = row[12] ##
      emergency_contact_name = row[49] ##
      emergency_contact_number = row[51] ##
      emergency_contact_relationship = row[50] ##
      saturday_early_housing = row[32] ##
      sunday_early_housing = row[33] ##
      liability_form_received = row[61] ##
      #is_quizzer = row[37] ## 
      #is_coach = row[38] ##
      planning_on_coaching = row[41] == 'Yes' ? 1 : 0 ##
      coaching_team = row[42] ##
      planning_on_officiating = row[43] == 'Yes' ? 1 : 0 ##
      coaching_team_2 = row[44] ##
      group_leader_email = row[62]
      staying_off_campus = row[64]
      
      # departure airline (sigh cvent sigh)
      for i in 57..58
        departure_airline_name = row[i] if !row[i].nil? ##
      end
      
      # understand form submission (sigh cvent sigh)
      for i in 34..35
        understand_form_completion = row[i] if !row[i].nil? ##
      end
      
      # skip empty rows
      if full_name.nil?
        next
      end
      
      pr = ParticipantRegistration.find_by_confirmation_number(confirmation_number)
      pr = ParticipantRegistration.new if pr.nil?
      pr.first_name = first_name.strip
      pr.last_name = last_name
      #pr.guest_first_name = guest_first_name
      #pr.guest_last_name = guest_last_name
      pr.guest_last_name,pr.guest_first_name = guest_name.split(',').map(&:strip) if guest_type == "Guest"
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
      pr.group_leader_email = group_leader_email
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
      #pr.is_quizzer = is_quizzer
      #pr.is_coach = is_coach
      pr.planning_on_coaching = planning_on_coaching
      pr.planning_on_officiating = planning_on_officiating
      pr.coaching_team = coaching_team
      pr.coaching_team_2 = coaching_team_2
      pr.staying_off_campus = staying_off_campus

      # TODO: Is this being overwritten if changed?
      # try and figure out group leader based on group leader email
      unless group_leader_email.nil?
        group_leader = User.find(:first, :conditions => "lower(email) = '#{group_leader_email.downcase}'")
        unless group_leader.nil?
          pr.group_leader = group_leader
        end
      end

      # save the participant registration
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
          # create team placeholders
          #teams = Array.new
          #if user.num_experienced_district_teams_available > 0
          #  user.num_experienced_district_teams_available.times do
          #    division = Division.find_by_name("District Experienced")
          #    team = Team.new
          #    team.name = user.fullname + "'s District Experienced Team"
          #    team.division = division
          #    teams << team
          #  end
          #end
          #if user.num_novice_district_teams_available > 0
          #  user.num_novice_district_teams_available.times do
          #    division = Division.find_by_name("District Novice")
          #    team = Team.new
          #    team.name = user.fullname + "'s District Novice Team"
          #    team.division = division
          #    teams << team
          #  end
          #end
          #if user.num_experienced_local_teams_available > 0
          #  user.num_experienced_local_teams_available.times do
          #    division = Division.find_by_name("Local Experienced")
          #    team = Team.new
          #    team.name = user.fullname + "'s Local Experienced Team"
          #    team.division = division
          #    teams << team
          #  end
          #end
          #if user.num_novice_local_teams_available > 0
          #  user.num_novice_local_teams_available.times do
          #    division = Division.find_by_name("Local Novice")
          #    team = Team.new
          #    team.name = user.fullname + "'s Local Novice Team"
          #    team.division = division
          #    teams << team
          #  end
          #end
          #if teams.count > 0
          #  team_registration = TeamRegistration.new
          #  team_registration.user = user
          #  team_registration.audit_user = user
          #  team_registration.first_name = user.first_name
          #  team_registration.last_name = user.last_name
          #  team_registration.phone = user.phone
          #  team_registration.email = user.email
          #  team_registration.district = user.district
          #  team_registration.paid = true
          #  team_registration.amount_in_cents = 0
          #  teams.each do |team|
          #    team_registration.teams << team
          #  end
          #  team_registration.save
          #end
        end
      end
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
          unless pr.nil?
            pr.send("#{correction[1]}=".to_sym, correction[2])
            pr.save(false)
          end
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
