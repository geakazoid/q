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
    FasterCSV.foreach(path, :quote_char => '"', :col_sep => ',') do |row|
      if first_row
        first_row = false
        next
      end
      
      first_name = row[1]
      last_name = row[2]
      registration_type = row[3].downcase
      district_name = row[4]
      field = row[5]
      email_address = row[6]
      home_address = row[7]
      home_city = row[8]
      home_state_prov = row[9]
      home_zipcode = row[10]
      mobile_phone = row[11]
      grade_completed = row[12]
      special_needs_details = row[16]
      emergency_contact_name = row[13]
      emergency_contact_number = row[14]
      emergency_contact_email = row[15]
      medical_liability = row[17]
      
      # doesn't currently handle more than one import
      pr = ParticipantRegistration.new
      pr.first_name = first_name.strip
      pr.last_name = last_name.strip
      pr.email = email_address
      registration_type = 'staff' if registration_type == "volunteer&staff"
      pr.registration_type = registration_type
      pr.mobile_phone = mobile_phone
      pr.street = home_address
      pr.city = home_city
      pr.state = home_state_prov
      pr.zipcode = home_zipcode
      pr.most_recent_grade = grade_completed
      pr.special_needs_details = special_needs_details
      pr.emergency_contact_name = emergency_contact_name
      pr.emergency_contact_number = emergency_contact_number
      pr.emergency_contact_relationship = emergency_contact_email
      district = District.find_by_name(district_name)
      pr.district = district unless district.nil?
      pr.medical_liability = true if medical_liability == "YES"

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
