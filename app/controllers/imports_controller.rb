class ImportsController < ApplicationController
  require_role ['admin']
  
  # GET /imports/participants
  # lists participants import page
  def participants
  end
  
  # POST /imports/upload_participants_file
  def upload_participants_file
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
