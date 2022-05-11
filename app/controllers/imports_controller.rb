class ImportsController < ApplicationController
  require_role ['admin']
  
  # GET /imports
  # lists participants import page
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
    FasterCSV.foreach(path, :quote_char => '"', :col_sep => ',', :converters => lambda{|v| v || ""}) do |row|
      if first_row
        first_row = false
        next
      end
      
      confirmation_number = row[0].strip
      first_name = row[1].strip
      last_name = row[2].strip
      gender = row[6].strip
      gender = gender == 'M' ? 'Male' : 'Female'
      graduation_year = row[46].strip
      registration_type = row[30].strip.downcase
      shirt_size = row[47].strip
      group_leader = row[53].strip
      group_leader_email = row[54].strip
      coach_name = row[51].strip

      # where is the user from?
      local_church = row[43].strip
      district_name = row[44].strip

      # phone logic (multiple fields)
      home_phone = row[8].strip
      if home_phone.empty?
        home_phone = row[9].strip
      end
      if home_phone.empty?
        home_phone = row[10].strip
      end

      # email logic (multiple fields)
      email_address = row[15].strip
      if email_address.empty?
        email_address = row[16].strip
      end
      if email_address.empty?
        email_address = row[17].strip
      end

      # special needs
      food_allergies_details = row[56].strip
      special_needs_details = row[57].strip

      # roommate preference
      roommate_preference = row[60].strip
      roommate_notes = row[61].strip
      
      # plans
      planning_on_officiating = row[48].strip.downcase
      planning_on_coaching = row[49].strip.downcase
      travel_type = row[63].strip

      # emergency contact logic
      emergency_contact = row[34].split(' - ')
      emergency_contact_name = emergency_contact[0].strip unless emergency_contact[0].nil?
      emergency_contact_number = emergency_contact[1].strip unless emergency_contact[1].nil?

      # add ons
      airport_shuttle = row[68].strip
      housing_sunday = row[69].strip
      
      pr = ParticipantRegistration.find_by_confirmation_number_and_first_name_and_last_name(confirmation_number,first_name,last_name)
      if pr.nil?
        pr = ParticipantRegistration.new
      end

      pr.first_name = first_name
      pr.last_name = last_name
      pr.gender = gender
      pr.email = email_address
      registration_type = 'staff' if registration_type == "staff/intern"
      registration_type = 'official' if registration_type == "official/volunteer"
      pr.registration_type = registration_type
      pr.home_phone = home_phone
      pr.shirt_size = shirt_size
      pr.group_leader_text = group_leader
      pr.group_leader_email = group_leader_email
      pr.coach_name = coach_name
      pr.graduation_year = graduation_year
      pr.special_needs_food_allergies = false # hardcoded due to how Q2022 registration asks this question
      pr.special_needs_other = false # hardcoded due to how Q2022 registration asks this question
      pr.special_needs_details = 'Special Needs: ' + special_needs_details + "\r\n" + 'Food Allergies: ' + food_allergies_details
      pr.emergency_contact_name = emergency_contact_name
      pr.emergency_contact_number = emergency_contact_number
      pr.roommate_preference_1 = roommate_preference
      pr.roommate_notes = roommate_notes
      pr.planning_on_officiating = true if planning_on_officiating == "yes"
      pr.planning_on_coaching = true if planning_on_coaching == "yes"
      pr.planning_on_officiating = false if planning_on_officiating == "no"
      pr.planning_on_coaching = false if planning_on_coaching == "no"
      district = District.find_by_name(district_name)
      pr.district = district unless district.nil?
      pr.local_church = local_church
      pr.need_arrival_shuttle = true if airport_shuttle == 1
      pr.housing_sunday = true if housing_sunday == 1
      pr.event_id = 6 # q2022
      pr.confirmation_number = confirmation_number
      pr.travel_type = travel_type
      pr.paid = true

      # save the participant registration
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
