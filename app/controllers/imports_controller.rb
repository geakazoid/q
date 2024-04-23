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
      # gender = gender == 'M' ? 'Male' : 'Female'
      # graduation_year = row[54].strip # removed
      registration_type = row[37].strip.downcase
      shirt_size = row[60].strip
      group_leader = row[66].strip
      group_leader_email = row[67].strip
      coach_name = row[64].strip

      # where is the user from?
      local_church = row[58].strip
      district_name = row[57].strip

      # phone logic (multiple fields) # removed
      # home_phone = row[8].strip
      # if home_phone.empty?
      #   home_phone = row[9].strip
      # end
      # if home_phone.empty?
      #   home_phone = row[10].strip
      # end

      # email logic (multiple fields)
      email_address = row[15].strip
      if email_address.empty?
        email_address = row[16].strip
      end
      if email_address.empty?
        email_address = row[17].strip
      end

      # special needs
      # food_allergies_details = row[64].strip # removed
      special_needs_details = row[70].strip

      # roommate preference
      roommate_preference = row[72].strip
      roommate_notes = row[73].strip
      
      # plans
      planning_on_officiating = row[61].strip.downcase
      planning_on_coaching = row[62].strip.downcase
      travel_type = row[75].strip

      # emergency contact logic # removed
      # emergency_contact = row[41].split(' - ')
      # emergency_contact_name = emergency_contact[0].strip unless emergency_contact[0].nil?
      # emergency_contact_number = emergency_contact[1].strip unless emergency_contact[1].nil?

      # add ons
      decades_quizzing = row[77].strip
      housing_sunday = row[78].strip
      airport_shuttle = row[81].strip
      linens = row[80].strip
      
      pr = ParticipantRegistration.find_by_confirmation_number_and_first_name_and_last_name(confirmation_number,first_name,last_name)
      if pr.nil?
        pr = ParticipantRegistration.new
      end

      pr.first_name = first_name
      pr.last_name = last_name
      pr.gender = gender
      pr.email = email_address
      registration_type = 'staff' if registration_type == "staff/intern"
      registration_type = 'official' if registration_type == "Officials/Tech Team (invite only)"
      pr.registration_type = registration_type
      #pr.home_phone = home_phone
      pr.shirt_size = shirt_size
      pr.group_leader_text = group_leader
      pr.group_leader_email = group_leader_email
      pr.coach_name = coach_name
      #pr.graduation_year = graduation_year
      #pr.special_needs_food_allergies = false # hardcoded due to how Q2024 registration asks this question
      pr.special_needs_other = false # hardcoded due to how Q2024 registration asks this question
      pr.special_needs_details = 'Special Needs: ' + special_needs_details
      #pr.emergency_contact_name = emergency_contact_name
      #pr.emergency_contact_number = emergency_contact_number
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
      pr.event_id = 10 # q2024
      pr.confirmation_number = confirmation_number
      pr.travel_type = travel_type
      pr.paid = true

      # registration options
      ro_decades_quizzing = RegistrationOption.find(:first, :conditions => [ "event_id = 10 and item = 'Decades Quizzing'" ])
      ro_sunday_housing = RegistrationOption.find(:first, :conditions => [ "event_id = 10 and item = 'Sunday Night Housing - June 23'" ])
      ro_airport_shuttle = RegistrationOption.find(:first, :conditions => [ "event_id = 10 and item = 'Airport Shuttle'" ])
      ro_linens = RegistrationOption.find(:first, :conditions => [ "event_id = 10 and item = 'Linens'" ])
      pr.registration_options.clear
      if decades_quizzing == "1"
        pr.registration_options << ro_decades_quizzing
      end
      if housing_sunday == "1"
        pr.registration_options << ro_sunday_housing
      end
      if airport_shuttle == "1"
        pr.registration_options << ro_airport_shuttle
      end
      if linens == "1"
        pr.registration_options << ro_linens
      end

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
