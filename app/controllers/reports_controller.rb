class ReportsController < ApplicationController
  require "spreadsheet"
  require_role ['admin','housing_admin','seminar_admin','ministry_project_admin','equipment_admin'], :except => :group_leader_summary

  # GET /reports
  # lists all available reports
  def index
    # populate group leaders
    @group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }.uniq
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
    @group_leaders.push(['Group Leader Not Listed', -1])
    @group_leaders.push(['Group Leader Not Known', -2])
    @group_leaders.push(['No Group Leader', -3])

    # populate buildings
    @buildings = Building.all

    # populate ministry projects
    @ministry_projects = MinistryProject.all
  end
  
  # generate a report of all team registrations
  def team_registrations_all
    @team_registrations = TeamRegistration.all
    @report_type = 'all'
    team_registrations
  end

  # generate a report of complete team registrations
  def team_registrations_complete
    @team_registrations = TeamRegistration.all(:conditions => 'paid = 1')
    @report_type = 'complete'
    team_registrations
  end

  # generate a report of incomplete team registrations
  def team_registrations_incomplete
    @team_registrations = TeamRegistration.all(:conditions => 'paid = 0')
    @report_type = 'incomplete'
    team_registrations
  end

  # create a downloadable excel file of team registrations
  # this method should not be accessed directly
  def team_registrations
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    # write out headers
    sheet1[0,0] = 'First Name'
    sheet1[0,1] = 'Last Name'
    sheet1[0,2] = 'Phone'
    sheet1[0,3] = 'Email'
    sheet1[0,4] = 'Team Name'
    sheet1[0,5] = 'Division'
    sheet1[0,6] = 'District'
    sheet1[0,7] = 'Region'
    sheet1[0,8] = 'Paid?'
    sheet1[0,9] = 'Amount'
    sheet1[0,10] = 'Discounted?'
    sheet1[0,11] = 'Registration Time'

    pos = 1
    @team_registrations.each do |team_registration|
      team_registration.teams.each do |team|
        sheet1[pos,0] = team_registration.first_name
        sheet1[pos,1] = team_registration.last_name
        sheet1[pos,2] = team_registration.phone
        sheet1[pos,3] = team_registration.email
        sheet1[pos,4] = team.name
        sheet1[pos,5] = team.division.name
        sheet1[pos,6] = team_registration.district.name
        sheet1[pos,7] = team_registration.district.region.name
        sheet1[pos,8] = team_registration.paid?
        sheet1[pos,9] = team.amount_in_cents / 100 if team_registration.complete?
        sheet1[pos,10] = team.discounted? if team_registration.complete?
        sheet1[pos,11] = team_registration.created_at.strftime("%m/%d/%Y %H:%M:%S")
        pos = pos + 1
      end
    end
    book.write "#{RAILS_ROOT}/public/download/team_registrations_#{@report_type}.xls"

    send_file "#{RAILS_ROOT}/public/download/team_registrations_#{@report_type}.xls", :filename => "team_registrations_#{@report_type}.xls"
  end

  # generate a report of all participant registrations
  def participant_registrations_all
    @participant_registrations = ParticipantRegistration.all(:order => 'last_name asc, first_name asc')
    @report_type = 'all'
    participant_registrations
  end

  # generate a report of complete participant registrations
  def participant_registrations_complete
    @participant_registrations = ParticipantRegistration.all(:conditions => 'paid = 1', :order => 'last_name asc, first_name asc')
    @report_type = 'complete'
    participant_registrations
  end

  # generate a report of incomplete participant registrations
  def participant_registrations_incomplete
    @participant_registrations = ParticipantRegistration.all(:conditions => 'paid = 0', :order => 'last_name asc, first_name asc')
    @report_type = 'incomplete'
    participant_registrations
  end

  # create a downloadable excel file of participant registrations
  # this method should not be accessed directly
  def participant_registrations
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    # write out headers
    column = 0
    sheet1[0,column] = 'ID'
    sheet1[0,column+=1] = 'Registration Type'
    sheet1[0,column+=1] = 'Full Name'
    sheet1[0,column+=1] = 'First Name'
    sheet1[0,column+=1] = 'Last Name'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'Address'
    sheet1[0,column+=1] = 'City'
    sheet1[0,column+=1] = 'State'
    sheet1[0,column+=1] = 'Zipcode'
    sheet1[0,column+=1] = 'Gender'
    sheet1[0,column+=1] = 'Age / Most Recent Grade'
    sheet1[0,column+=1] = 'Home Phone'
    sheet1[0,column+=1] = 'Mobile Phone'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'Local Church'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Region'
    sheet1[0,column+=1] = 'Shirt Size'
    sheet1[0,column+=1] = 'Roommate Preference 1'
    sheet1[0,column+=1] = 'Roommate Preference 2'
    sheet1[0,column+=1] = 'Team 1'
    sheet1[0,column+=1] = 'Team 2'
    sheet1[0,column+=1] = 'Team 3'
    sheet1[0,column+=1] = 'Housing Assignment'
    sheet1[0,column+=1] = 'Ministry Project'
    sheet1[0,column+=1] = 'Food Allergies?'
    sheet1[0,column+=1] = 'Food Allergy Details'
    sheet1[0,column+=1] = 'Special Needs?'
    sheet1[0,column+=1] = 'Special Needs Details'
    sheet1[0,column+=1] = 'Needs Housing'
    sheet1[0,column+=1] = 'Needs Meals'
    sheet1[0,column+=1] = 'Guardian'
    sheet1[0,column+=1] = 'Agrees To Promotion'
    sheet1[0,column+=1] = 'Exhibitor School'
    sheet1[0,column+=1] = 'Exhibitor School Fax'
    sheet1[0,column+=1] = 'Travel Type'
    sheet1[0,column+=1] = 'Arrival Date'
    sheet1[0,column+=1] = 'Arrival Time'
    sheet1[0,column+=1] = 'Arrival Airline'
    sheet1[0,column+=1] = 'Arrival Airline Flight Number'
    sheet1[0,column+=1] = 'Arriving From'
    sheet1[0,column+=1] = 'Arrival Shuttle'
    sheet1[0,column+=1] = 'Departure Date'
    sheet1[0,column+=1] = 'Departure Time'
    sheet1[0,column+=1] = 'Departure Airline'
    sheet1[0,column+=1] = 'Departure Airline Flight Number'
    sheet1[0,column+=1] = 'Departure Shuttle'
    sheet1[0,column+=1] = 'Housing Sunday'
    sheet1[0,column+=1] = 'Housing Saturday'
    sheet1[0,column+=1] = 'Breakfast Monday'
    sheet1[0,column+=1] = 'Lunch Monday'
    sheet1[0,column+=1] = 'Group Photos Purchased'
    sheet1[0,column+=1] = 'Group Photos Amount'
    sheet1[0,column+=1] = 'Event DVDs Purchased'
    sheet1[0,column+=1] = 'Event DVDs Amount'
    sheet1[0,column+=1] = 'Youth Small Shirts Purchased'
    sheet1[0,column+=1] = 'Youth Small Shirts Amount'
    sheet1[0,column+=1] = 'Youth Medium Shirts Purchased'
    sheet1[0,column+=1] = 'Youth Medium Shirts Amount'
    sheet1[0,column+=1] = 'Youth Large Shirts Purchased'
    sheet1[0,column+=1] = 'Youth Large Shirts Amount'
    sheet1[0,column+=1] = 'Small Shirts Purchased'
    sheet1[0,column+=1] = 'Small Shirts Amount'
    sheet1[0,column+=1] = 'Medium Shirts Purchased'
    sheet1[0,column+=1] = 'Medium Shirts Amount'
    sheet1[0,column+=1] = 'Large Shirts Purchased'
    sheet1[0,column+=1] = 'Large Shirts Amount'
    sheet1[0,column+=1] = 'X-Large Shirts Purchased'
    sheet1[0,column+=1] = 'X-Large Shirts Amount'
    sheet1[0,column+=1] = '2X-Large Shirts Purchased'
    sheet1[0,column+=1] = '2X-Large Shirts Amount'
    sheet1[0,column+=1] = '3X-Large Shirts Purchased'
    sheet1[0,column+=1] = '3X-Large Shirts Amount'
    sheet1[0,column+=1] = '4X-Large Shirts Purchased'
    sheet1[0,column+=1] = '4X-Large Shirts Amount'
    sheet1[0,column+=1] = '5X-Large Shirts Purchased'
    sheet1[0,column+=1] = '5X-Large Shirts Amount'
    sheet1[0,column+=1] = 'Splash Valley Tickets Purchased'
    sheet1[0,column+=1] = 'Splash Valley Transportation Needed?'
    sheet1[0,column+=1] = 'Splash Valley Tickets Amount'
    sheet1[0,column+=1] = 'Complete?'
    sheet1[0,column+=1] = 'Medical / Liability?'
    sheet1[0,column+=1] = 'Background Check?'
    sheet1[0,column+=1] = 'NazSafe?'
    sheet1[0,column+=1] = 'Registration Fee'
    sheet1[0,column+=1] = 'Registration Due'
    sheet1[0,column+=1] = 'Extras Due'
    sheet1[0,column+=1] = 'Total Due'
    sheet1[0,column+=1] = 'Discount Applied'
    sheet1[0,column+=1] = 'Registration Paid'
    sheet1[0,column+=1] = 'Extras Paid'
    sheet1[0,column+=1] = 'Total Paid'
    sheet1[0,column+=1] = 'Created On'
    sheet1[0,column+=1] = 'Updated On'

    pos = 1
    @participant_registrations.each do |participant_registration|
      column = 0
      sheet1[pos,column] = participant_registration.id
      sheet1[pos,column+=1] = participant_registration.registration_type
      sheet1[pos,column+=1] = participant_registration.full_name
      sheet1[pos,column+=1] = participant_registration.first_name
      sheet1[pos,column+=1] = participant_registration.last_name
      sheet1[pos,column+=1] = participant_registration.email
      sheet1[pos,column+=1] = participant_registration.street
      sheet1[pos,column+=1] = participant_registration.city
      sheet1[pos,column+=1] = participant_registration.state
      sheet1[pos,column+=1] = participant_registration.zipcode
      sheet1[pos,column+=1] = participant_registration.gender
      sheet1[pos,column+=1] = participant_registration.most_recent_grade
      sheet1[pos,column+=1] = participant_registration.home_phone
      sheet1[pos,column+=1] = participant_registration.mobile_phone
      sheet1[pos,column+=1] = participant_registration.group_leader_name
      sheet1[pos,column+=1] = participant_registration.local_church
      sheet1[pos,column+=1] = participant_registration.district.name
      sheet1[pos,column+=1] = participant_registration.district.region.name
      sheet1[pos,column+=1] = participant_registration.shirt_size
      sheet1[pos,column+=1] = participant_registration.roommate_preference_1
      sheet1[pos,column+=1] = participant_registration.roommate_preference_2

      # teams
      team1 = Team.find(participant_registration.team1_id) unless participant_registration.team1_id.blank?
      team2 = Team.find(participant_registration.team2_id) unless participant_registration.team2_id.blank?
      team3 = Team.find(participant_registration.team3_id) unless participant_registration.team3_id.blank?

      if !team1.nil?
        sheet1[pos,column+=1] = team1.name_with_division
      else
        sheet1[pos,column+=1] = ''
      end
      if !team2.nil?
        sheet1[pos,column+=1] = team2.name_with_division
      else
        sheet1[pos,column+=1] = ''
      end
      if !team3.nil?
        sheet1[pos,column+=1] = team3.name_with_division
      else
        sheet1[pos,column+=1] = ''
      end

      # housing
      if !participant_registration.building.nil? or !participant_registration.room.blank?
        assignment = ''
        assignment += participant_registration.building ? participant_registration.building.name : ''
        assignment += !participant_registration.room.blank? ? ' - ' + participant_registration.room : ''
        sheet1[pos,column+=1] = assignment
      else
        sheet1[pos,column+=1] = ''
      end

      # ministry project
      if !participant_registration.ministry_project.nil? or !participant_registration.ministry_project_group.blank?
        assignment = ''
        assignment += participant_registration.ministry_project ? participant_registration.ministry_project.name : ''
        assignment += !participant_registration.ministry_project_group.blank? ? ' - ' + participant_registration.ministry_project_group : ''
        sheet1[pos,column+=1] = assignment
      else
        sheet1[pos,column+=1] = ''
      end

      sheet1[pos,column+=1] = participant_registration.food_allergies.upcase
      sheet1[pos,column+=1] = participant_registration.food_allergies_details
      sheet1[pos,column+=1] = participant_registration.special_needs.upcase
      sheet1[pos,column+=1] = participant_registration.special_needs_details

      # needs housing?
      if participant_registration.exhibitor? and participant_registration.exhibitor_housing == 'on_campus'
        sheet1[pos,column+=1] = 'YES'
      elsif !participant_registration.exhibitor? and participant_registration.participant_housing == 'meals_and_housing'
        sheet1[pos,column+=1] = 'YES'
      else
        sheet1[pos,column+=1] = 'NO'
      end

      # needs meals?
      if participant_registration.exhibitor? and participant_registration.exhibitor_housing == 'on_campus'
        sheet1[pos,column+=1] = 'YES'
      elsif participant_registration.exhibitor? and participant_registration.exhibitor_housing == 'off_campus_with_meals'
        sheet1[pos,column+=1] = 'YES'
      elsif !participant_registration.exhibitor? and participant_registration.participant_housing == 'meals_and_housing'
        sheet1[pos,column+=1] = 'YES'
      elsif !participant_registration.exhibitor? and participant_registration.participant_housing == 'meals_only'
        sheet1[pos,column+=1] = 'YES'
      else
        sheet1[pos,column+=1] = 'NO'
      end

      sheet1[pos,column+=1] = participant_registration.guardian
      sheet1[pos,column+=1] = participant_registration.promotion_agree.upcase

      # school name (if it exists)
      if !participant_registration.school.nil?
        sheet1[pos,column+=1] = participant_registration.school.name
      else
        sheet1[pos,column+=1] = ''
      end

      sheet1[pos,column+=1] = participant_registration.school_fax
      sheet1[pos,column+=1] = participant_registration.travel_type

      # arrival date
      if participant_registration.travel_type == 'driving'
        sheet1[pos,column+=1] = participant_registration.driving_arrival_date
        sheet1[pos,column+=1] = participant_registration.driving_arrival_time
      elsif participant_registration.travel_type == 'flying'
        sheet1[pos,column+=1] = participant_registration.airline_arrival_date
        sheet1[pos,column+=1] = participant_registration.airline_arrival_time
      else
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
      end

      sheet1[pos,column+=1] = participant_registration.arrival_airline
      sheet1[pos,column+=1] = participant_registration.arrival_flight_number
      sheet1[pos,column+=1] = participant_registration.airline_arrival_from
      sheet1[pos,column+=1] = participant_registration.arrival_shuttle_amount ? participant_registration.arrival_shuttle_amount : ''
      sheet1[pos,column+=1] = participant_registration.airline_departure_date
      sheet1[pos,column+=1] = participant_registration.airline_departure_time
      sheet1[pos,column+=1] = participant_registration.departure_airline
      sheet1[pos,column+=1] = participant_registration.departure_flight_number
      sheet1[pos,column+=1] = participant_registration.departure_shuttle_amount ? participant_registration.departure_shuttle_amount : ''
      sheet1[pos,column+=1] = participant_registration.housing_sunday_amount ? participant_registration.housing_sunday_amount : ''
      sheet1[pos,column+=1] = participant_registration.housing_saturday_amount ? participant_registration.housing_saturday_amount : ''
      sheet1[pos,column+=1] = participant_registration.breakfast_monday_amount ? participant_registration.breakfast_monday_amount : ''
      sheet1[pos,column+=1] = participant_registration.lunch_monday_amount ? participant_registration.lunch_monday_amount : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_group_photos') > 0 ? participant_registration.count_bought_extra('num_extra_group_photos') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_group_photos') * 2 > 0 ? participant_registration.count_bought_extra('num_extra_group_photos') * 2 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_dvd') > 0 ? participant_registration.count_bought_extra('num_dvd') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_dvd') * 17 > 0 ? participant_registration.count_bought_extra('num_dvd') * 17 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_youth_small_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_youth_small_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_youth_small_shirts') * 10 > 0 ? participant_registration.count_bought_extra('num_extra_youth_small_shirts') * 10 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_youth_medium_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_youth_medium_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_youth_medium_shirts') * 10 > 0 ? participant_registration.count_bought_extra('num_extra_youth_medium_shirts') * 10 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_youth_large_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_youth_large_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_youth_large_shirts') * 10 > 0 ? participant_registration.count_bought_extra('num_extra_youth_large_shirts') * 10 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_small_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_small_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_small_shirts') * 10 > 0 ? participant_registration.count_bought_extra('num_extra_small_shirts') * 10 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_medium_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_medium_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_medium_shirts') * 10 > 0 ? participant_registration.count_bought_extra('num_extra_medium_shirts') * 10 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_large_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_large_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_large_shirts') * 10 > 0 ? participant_registration.count_bought_extra('num_extra_large_shirts') * 10 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_xlarge_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_xlarge_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_xlarge_shirts') * 10 > 0 ? participant_registration.count_bought_extra('num_extra_xlarge_shirts') * 10 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_2xlarge_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_2xlarge_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_2xlarge_shirts') * 15 > 0 ? participant_registration.count_bought_extra('num_extra_2xlarge_shirts') * 15 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_3xlarge_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_3xlarge_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_3xlarge_shirts') * 15 > 0 ? participant_registration.count_bought_extra('num_extra_3xlarge_shirts') * 15 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_4xlarge_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_4xlarge_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_4xlarge_shirts') * 15 > 0 ? participant_registration.count_bought_extra('num_extra_4xlarge_shirts') * 15 : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_5xlarge_shirts') > 0 ? participant_registration.count_bought_extra('num_extra_5xlarge_shirts') : ''
      sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_extra_5xlarge_shirts') * 15 > 0 ? participant_registration.count_bought_extra('num_extra_5xlarge_shirts') * 15 : ''
      if participant_registration.count_bought_extra('num_sv_tickets') > 0
        sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_sv_tickets')
        if participant_registration.sv_transportation?
          sheet1[pos,column+=1] = 'YES'
          sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_sv_tickets') * 7
        else
          sheet1[pos,column+=1] = 'NO'
          sheet1[pos,column+=1] = participant_registration.count_bought_extra('num_sv_tickets') * 6
        end
      else
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
      end
      sheet1[pos,column+=1] = participant_registration.complete? ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant_registration.medical_liability? ? 'YES' : 'NO'
      if participant_registration.needs_background_check?
        sheet1[pos,column+=1] = participant_registration.background_check? ? 'YES' : 'NO'
        sheet1[pos,column+=1] = participant_registration.nazsafe? ? 'YES' : 'NO'
      else
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
      end
      sheet1[pos,column+=1] = participant_registration.registration_fee / 100
      sheet1[pos,column+=1] = participant_registration.registration_amount_due
      sheet1[pos,column+=1] = participant_registration.extras_amount_due
      sheet1[pos,column+=1] = participant_registration.total_amount_due
      sheet1[pos,column+=1] = participant_registration.applied_discount
      sheet1[pos,column+=1] = participant_registration.paid_registration_amount
      sheet1[pos,column+=1] = participant_registration.paid_extras_amount
      sheet1[pos,column+=1] = participant_registration.total_paid_amount
      sheet1[pos,column+=1] = participant_registration.created_at.strftime("%m/%d/%Y %H:%M:%S")
      sheet1[pos,column+=1] = participant_registration.updated_at.strftime("%m/%d/%Y %H:%M:%S")
      pos += 1
    end
    book.write "#{RAILS_ROOT}/public/download/participant_registrations_#{@report_type}.xls"

    send_file "#{RAILS_ROOT}/public/download/participant_registrations_#{@report_type}.xls", :filename => "participant_registrations_#{@report_type}.xls"
  end

  # generate a report of coaches and teams (this only grabs coaches with a complete registration)
  def coaches_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => 'paid = 1 and registration_type = "coach"', :order => 'last_name asc, first_name asc')
    @report_type = 'coaches'
    participants_teams
  end

  # generate a report of quizzers and teams (this only grabs quizzers with a complete registration)
  def quizzers_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => 'paid = 1 and registration_type = "quizzer"', :order => 'last_name asc, first_name asc')
    @report_type = 'quizzers'
    participants_teams
  end

  # generate a report of coaches, quizzers and teams (this only grabs coaches and quizzers with a complete registration)
  def coaches_quizzers_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => 'paid = 1 and (registration_type = "quizzer" or registration_type = "coach")', :order => 'first_name asc, last_name asc')
    @report_type = 'coaches_quizzers'
    participants_teams
  end

  # create a downloadable excel of participants and teams
  # this method should not be called directly
  def participants_teams
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # write out headers
    column = 0
    sheet1[0,column] = 'Participant Name'
    sheet1[0,column+=1] = 'Team Name'
    sheet1[0,column+=1] = 'Division'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Region'

    pos = 1
    @participant_registrations.each do |participant_registration|

      # teams
      team1 = Team.find(participant_registration.team1_id) unless participant_registration.team1_id.blank?
      team2 = Team.find(participant_registration.team2_id) unless participant_registration.team2_id.blank?
      team3 = Team.find(participant_registration.team3_id) unless participant_registration.team3_id.blank?

      if !team1.nil?
        column = 0
        sheet1[pos,column] = participant_registration.full_name
        sheet1[pos,column+=1] = team1.name
        sheet1[pos,column+=1] = team1.division.name
        sheet1[pos,column+=1] = participant_registration.district.name
        sheet1[pos,column+=1] = participant_registration.district.region.name
        pos += 1
      end
      if !team2.nil?
        column = 0
        sheet1[pos,column] = participant_registration.full_name
        sheet1[pos,column+=1] = team2.name
        sheet1[pos,column+=1] = team2.division.name
        sheet1[pos,column+=1] = participant_registration.district.name
        sheet1[pos,column+=1] = participant_registration.district.region.name
        pos += 1
      end
      if !team3.nil?
        column = 0
        sheet1[pos,column] = participant_registration.full_name
        sheet1[pos,column+=1] = team3.name
        sheet1[pos,column+=1] = team3.division.name
        sheet1[pos,column+=1] = participant_registration.district.name
        sheet1[pos,column+=1] = participant_registration.district.region.name
        pos += 1
      end
    end

    book.write "#{RAILS_ROOT}/public/download/#{@report_type}_teams.xls"

    send_file "#{RAILS_ROOT}/public/download/#{@report_type}_teams.xls", :filename => "#{@report_type}_teams.xls"
  end

  # create a downloadable excel of group leaders
  def group_leaders
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # write out headers
    column = 0
    sheet1[0,column] = 'Name'
    sheet1[0,column+=1] = 'Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Region'

    @ids = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| [user.id] }.uniq
    @group_leaders = User.find(@ids)

    pos = 1
    @group_leaders.each do |group_leader|
      column = 0
      sheet1[pos,column] = group_leader.fullname
      sheet1[pos,column+=1] = group_leader.phone
      sheet1[pos,column+=1] = group_leader.email
      sheet1[pos,column+=1] = group_leader.district.nil? ? '' : group_leader.district.name
      sheet1[pos,column+=1] = group_leader.region.nil? ? '' : group_leader.region.name
      pos += 1
    end

    book.write "#{RAILS_ROOT}/public/download/group_leaders.xls"

    send_file "#{RAILS_ROOT}/public/download/group_leaders.xls", :filename => "group_leaders.xls"
  end

  # group leader summary report used for check in at the event
  # produces an excel document for download based upon the passed in group leader id
  def group_leader_summary
    book = Spreadsheet::Workbook.new

    if (!params['group_leader'].blank?)
      sheet1 = book.create_worksheet

      if (params['group_leader'] == '-1')
        group_leader_name = 'Group Leader Not Listed'
        file_name = 'group_leader_not_listed'
        participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-1)
      elsif (params['group_leader'] == '-2')
        group_leader_name = 'Group Leader Not Known'
        file_name = 'group_leader_not_known'
        participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-2)
      elsif (params['group_leader'] == '-3')
        group_leader_name = 'No Group Leader'
        file_name = 'no_group_leader'
        participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-3)
      elsif (params['group_leader'] == '-4')
        group_leader_name = 'Staff'
        file_name = 'staff'
        participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-4)
      elsif (params['group_leader'] == '-5')
        group_leader_name = 'Official'
        file_name = 'official'
        participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-5)
      elsif (params['group_leader'] == '-6')
        group_leader_name = 'Volunteer'
        file_name = 'volunteer'
        participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-6)
      else
        group_leader = User.find(params['group_leader'])
        group_leader_name = group_leader.fullname
        file_name = (group_leader.first_name + '_' + group_leader.last_name).downcase
        participants = group_leader.followers
      end

      # formatting
      title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
      group_leader_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
      group_header_format = Spreadsheet::Format.new :weight => :bold, :align => :merge, :size => 9
      header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify, :size => 9
      data_format = Spreadsheet::Format.new :size => 9

      # write out title
      column = 0
      sheet1[0,column] = 'Group Summary'
      sheet1[0,column+=1] = 'Group Leader: ' + group_leader_name
      sheet1.row(0).set_format(0,title_format)
      sheet1.row(0).set_format(1,group_leader_format)

      # write out group headers
      sheet1[1,8] = 'Extras'
      sheet1[1,13] = 'Extra Housing'
      sheet1[1,15] = 'Extra Meals'
      sheet1[1,17] = 'Shuttles'
      for i in 8..18
        sheet1.row(1).set_format(i,group_header_format)
      end

      # write out headers
      column = 0
      sheet1[2,column] = 'Name'
      sheet1[2,column+=1] = 'Role'
      sheet1[2,column+=1] = 'Gender'
      sheet1[2,column+=1] = 'Shirt Size'
      sheet1[2,column+=1] = 'Housing'
      sheet1[2,column+=1] = 'Ministry Project'
      sheet1[2,column+=1] = 'Team 1'
      sheet1[2,column+=1] = 'Team 2'
      sheet1[2,column+=1] = 'Team 3'
      sheet1[2,column+=1] = 'Extra Shirt Sizes'
      sheet1[2,column+=1] = 'Extra Pictures'
      sheet1[2,column+=1] = 'DVDs'
      sheet1[2,column+=1] = 'Splash Valley Tickets'
      sheet1[2,column+=1] = 'July 1st'
      sheet1[2,column+=1] = 'July 7th'
      sheet1[2,column+=1] = 'Breakfast July 2nd'
      sheet1[2,column+=1] = 'Lunch July 2nd'
      sheet1[2,column+=1] = 'Arrival Shuttle'
      sheet1[2,column+=1] = 'Departure Shuttle'
      sheet1[2,column+=1] = 'Medical Liability Received'
      sheet1[2,column+=1] = 'Amount Owed'
      sheet1.row(2).default_format = header_format

      pos = 3
      participants.each do |participant|
        column = 0
        sheet1[pos,column] = participant.full_name_reversed
        sheet1[pos,column+=1] = participant.formatted_registration_type
        sheet1[pos,column+=1] = participant.gender
        sheet1[pos,column+=1] = participant.shirt_size
        sheet1[pos,column+=1] = participant.housing

        # ministry project
        if !participant.ministry_project.nil? or !participant.ministry_project_group.blank?
          assignment = ''
          assignment += participant.ministry_project ? participant.ministry_project.name : ''
          assignment += !participant.ministry_project_group.blank? ? ' - ' + participant.ministry_project_group : ''
          sheet1[pos,column+=1] = assignment
        else
          sheet1[pos,column+=1] = ''
        end

        sheet1[pos,column+=1] = !participant.team1.nil? ? participant.team1.name : ''
        sheet1[pos,column+=1] = !participant.team2.nil? ? participant.team2.name : ''
        sheet1[pos,column+=1] = !participant.team3.nil? ? participant.team3.name : ''
        sheet1[pos,column+=1] = participant.extra_shirts
        sheet1[pos,column+=1] = participant.count_bought_extra('num_extra_group_photos') > 0 ? participant.count_bought_extra('num_extra_group_photos') : ''
        sheet1[pos,column+=1] = participant.count_bought_extra('num_dvd') > 0 ? participant.count_bought_extra('num_dvd') : ''
        sheet1[pos,column+=1] = participant.count_bought_extra('num_sv_tickets') > 0 ? participant.count_bought_extra('num_sv_tickets') : ''
        sheet1[pos,column+=1] = participant.bought_extra?('housing_sunday') ? 'YES' : ''
        sheet1[pos,column+=1] = participant.bought_extra?('housing_saturday') ? 'YES' : ''
        sheet1[pos,column+=1] = participant.bought_extra?('breakfast_monday') ? 'YES' : ''
        sheet1[pos,column+=1] = participant.bought_extra?('lunch_monday') ? 'YES' : ''
        sheet1[pos,column+=1] = participant.bought_extra?('need_arrival_shuttle') ? 'YES' : ''
        sheet1[pos,column+=1] = participant.bought_extra?('need_departure_shuttle') ? 'YES' : ''
        sheet1[pos,column+=1] = participant.medical_liability? ? 'YES' : ''
        sheet1[pos,column+=1] = participant.total_amount_due > 0 ? '$' + participant.total_amount_due.to_s : ''
        
        # set format
        for i in 1..19
          sheet1.row(pos).set_format(i,data_format)
        end
      
        pos += 1
      end

      sheet1.column(0).width = 30
      sheet1.column(1).width = 12
      sheet1.column(2).width = 12
      sheet1.column(3).width = 12
      sheet1.column(4).width = 30
      sheet1.column(5).width = 30
      sheet1.column(6).width = 30
      sheet1.column(7).width = 30
      sheet1.column(8).width = 30
      sheet1.column(9).width = 20

      book.write "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls", :filename => "group_leader_summary_#{file_name}.xls"
    else
      file_name = 'all'

      # loop through all group leaders
      group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| user.id }.uniq
      group_leaders.push(-1)
      group_leaders.push(-2)
      group_leaders.push(-3)
      group_leaders.push(-4)
      group_leaders.push(-5)
      group_leaders.push(-6)

      group_leaders.each do |leader|
        sheet1 = book.create_worksheet

        if (leader == -1)
          group_leader_name = 'Group Leader Not Listed'
          participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-1)
        elsif (leader == -2)
          group_leader_name = 'Group Leader Not Known'
          participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-2)
        elsif (leader == -3)
          group_leader_name = 'No Group Leader'
          participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-3)
        elsif (leader == -4)
          group_leader_name = 'Staff'
          participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-4)
        elsif (leader == -5)
          group_leader_name = 'Official'
          participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-5)
        elsif (leader == -6)
          group_leader_name = 'Volunteer'
          participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-6)
        else
          user = User.find(leader)
          group_leader_name = user.fullname
          participants = user.followers
        end

        # formatting
        title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
        group_leader_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
        group_header_format = Spreadsheet::Format.new :weight => :bold, :align => :merge, :size => 9
        header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify, :size => 9
        data_format = Spreadsheet::Format.new :size => 9

        # write out title
        column = 0
        sheet1[0,column] = 'Group Summary'
        sheet1[0,column+=1] = 'Group Leader: ' + group_leader_name
        sheet1.row(0).set_format(0,title_format)
        sheet1.row(0).set_format(1,group_leader_format)

        # write out group headers
        sheet1[1,9] = 'Extras'
        sheet1[1,13] = 'Extra Housing'
        sheet1[1,15] = 'Extra Meals'
        sheet1[1,17] = 'Shuttles'
        for i in 9..18
          sheet1.row(1).set_format(i,group_header_format)
        end

        # write out headers
        column = 0
        sheet1[2,column] = 'Name'
        sheet1[2,column+=1] = 'Role'
        sheet1[2,column+=1] = 'Gender'
        sheet1[2,column+=1] = 'Shirt Size'
        sheet1[2,column+=1] = 'Housing'
        sheet1[2,column+=1] = 'Ministry Project'
        sheet1[2,column+=1] = 'Team 1'
        sheet1[2,column+=1] = 'Team 2'
        sheet1[2,column+=1] = 'Team 3'
        sheet1[2,column+=1] = 'Extra Shirt Sizes'
        sheet1[2,column+=1] = 'Extra Pictures'
        sheet1[2,column+=1] = 'DVDs'
        sheet1[2,column+=1] = 'Splash Valley Tickets'
        sheet1[2,column+=1] = 'July 1st'
        sheet1[2,column+=1] = 'July 7th'
        sheet1[2,column+=1] = 'Breakfast July 2nd'
        sheet1[2,column+=1] = 'Lunch July 2nd'
        sheet1[2,column+=1] = 'Arrival Shuttle'
        sheet1[2,column+=1] = 'Departure Shuttle'
        sheet1[2,column+=1] = 'Medical Liability Received'
        sheet1[2,column+=1] = 'Amount Owed'
        sheet1.row(2).default_format = header_format

        pos = 3
        participants.each do |participant|
          column = 0
          sheet1[pos,column] = participant.full_name_reversed
          sheet1[pos,column+=1] = participant.formatted_registration_type
          sheet1[pos,column+=1] = participant.gender
          sheet1[pos,column+=1] = participant.shirt_size
          sheet1[pos,column+=1] = participant.housing

          # ministry project
          if !participant.ministry_project.nil? or !participant.ministry_project_group.blank?
            assignment = ''
            assignment += participant.ministry_project ? participant.ministry_project.name : ''
            assignment += !participant.ministry_project_group.blank? ? ' - ' + participant.ministry_project_group : ''
            sheet1[pos,column+=1] = assignment
          else
            sheet1[pos,column+=1] = ''
          end

          sheet1[pos,column+=1] = !participant.team1.nil? ? participant.team1.name : ''
          sheet1[pos,column+=1] = !participant.team2.nil? ? participant.team2.name : ''
          sheet1[pos,column+=1] = !participant.team3.nil? ? participant.team3.name : ''
          sheet1[pos,column+=1] = participant.extra_shirts
          sheet1[pos,column+=1] = participant.count_bought_extra('num_extra_group_photos') > 0 ? participant.count_bought_extra('num_extra_group_photos') : ''
          sheet1[pos,column+=1] = participant.count_bought_extra('num_dvd') > 0 ? participant.count_bought_extra('num_dvd') : ''
          sheet1[pos,column+=1] = participant.count_bought_extra('num_sv_tickets') > 0 ? participant.count_bought_extra('num_sv_tickets') : ''
          sheet1[pos,column+=1] = participant.bought_extra?('housing_sunday') ? 'YES' : ''
          sheet1[pos,column+=1] = participant.bought_extra?('housing_saturday') ? 'YES' : ''
          sheet1[pos,column+=1] = participant.bought_extra?('breakfast_monday') ? 'YES' : ''
          sheet1[pos,column+=1] = participant.bought_extra?('lunch_monday') ? 'YES' : ''
          sheet1[pos,column+=1] = participant.bought_extra?('need_arrival_shuttle') ? 'YES' : ''
          sheet1[pos,column+=1] = participant.bought_extra?('need_departure_shuttle') ? 'YES' : ''
          sheet1[pos,column+=1] = participant.medical_liability? ? 'YES' : ''
          sheet1[pos,column+=1] = participant.total_amount_due > 0 ? '$' + participant.total_amount_due.to_s : ''
          
          # set format
          for i in 1..19
            sheet1.row(pos).set_format(i,data_format)
          end
        
          pos += 1
        end

        sheet1.column(0).width = 30
        sheet1.column(1).width = 12
        sheet1.column(2).width = 12
        sheet1.column(3).width = 12
        sheet1.column(4).width = 30
        sheet1.column(5).width = 30
        sheet1.column(6).width = 30
        sheet1.column(7).width = 30
        sheet1.column(8).width = 30
        sheet1.column(9).width = 20

        sheet1.name = group_leader_name
      end

      book.write "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls", :filename => "group_leader_summary_#{file_name}.xls"
    end
  end

  # create a downloadable excel of equipment registrations
  def equipment_registrations
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    header_format = Spreadsheet::Format.new :weight => :bold, :horizontal_align => :left
    format = Spreadsheet::Format.new :horizontal_align => :distributed, :vertical_align => :top

    # write out headers
    column = 0
    sheet1[0,column] = 'Name'
    sheet1[0,column+=1] = 'Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Laptops'
    sheet1[0,column+=1] = 'Interface Boxes'
    sheet1[0,column+=1] = 'Pads'
    sheet1[0,column+=1] = 'Monitors'
    sheet1[0,column+=1] = 'Projectors'
    sheet1[0,column+=1] = 'Power Strips'
    sheet1[0,column+=1] = 'Extension Cords'
    sheet1[0,column+=1] = 'Recorders/Microphones'
    sheet1[0,column+=1] = 'Laptop Details'
    sheet1[0,column+=1] = 'Interface Box Details'
    sheet1[0,column+=1] = 'Pad Set Details'
    sheet1[0,column+=1] = 'Monitor Details'
    sheet1.row(0).default_format = header_format

    @equipment_registrations = EquipmentRegistration.all(:order => 'last_name asc')

    pos = 1
    @equipment_registrations.each do |equipment_registration|
      column = 0
      sheet1[pos,column] = equipment_registration.full_name
      sheet1[pos,column+=1] = equipment_registration.phone
      sheet1[pos,column+=1] = equipment_registration.email
      sheet1[pos,column+=1] = !equipment_registration.district.nil? ? equipment_registration.district.name : ''
      sheet1[pos,column+=1] = equipment_registration.laptops.size > 0 ? equipment_registration.laptops.size : ''
      sheet1[pos,column+=1] = equipment_registration.interface_boxes.size > 0 ? equipment_registration.interface_boxes.size : ''
      sheet1[pos,column+=1] = equipment_registration.pads.size > 0 ? equipment_registration.pads.size : ''
      sheet1[pos,column+=1] = equipment_registration.monitors.size > 0 ? equipment_registration.monitors.size : ''
      sheet1[pos,column+=1] = equipment_registration.projectors.size > 0 ? equipment_registration.projectors.size : ''
      sheet1[pos,column+=1] = equipment_registration.power_strips.size > 0 ? equipment_registration.power_strips.size : ''
      sheet1[pos,column+=1] = equipment_registration.extension_cords.size > 0 ? equipment_registration.extension_cords.size : ''
      sheet1[pos,column+=1] = equipment_registration.recorders.size > 0 ? equipment_registration.recorders.size : ''

      # laptop details
      if equipment_registration.laptops.size > 0
        text = ''
        count = 1
        equipment_registration.laptops.each do |laptop|
          text += 'Laptop ' + count.to_s + "\n"
          text += 'OS: ' + laptop.operating_system + "\n"
          text += 'Parallel Port: ' + laptop.parallel_port + "\n"
          text += 'Quizmachine Version: ' + laptop.quizmachine_version + "\n"
          text += 'Username: ' + laptop.username + "\n" unless laptop.username.blank?
          text += 'Password: ' + laptop.password + "\n" unless laptop.password.blank?
          text += "\n"
          count += 1
        end
        sheet1[pos,column+=1] = text
      else
        sheet1[pos,column+=1] = ''
      end

      # interface box details
      if equipment_registration.interface_boxes.size > 0
        text = ''
        count = 1
        equipment_registration.interface_boxes.each do |interface_box|
          text += 'Interface Box ' + count.to_s + "\n"
          text += 'Type: ' + interface_box.ib_type + "\n"
          text += "\n"
          count += 1
        end
        sheet1[pos,column+=1] = text
      else
        sheet1[pos,column+=1] = ''
      end

      # pad set details
      if equipment_registration.pads.size > 0
        text = ''
        count = 1
        equipment_registration.pads.each do |string|
          text += 'String ' + count.to_s + "\n"
          text += 'Color: ' + string.color + "\n"
          text += "\n"
          count += 1
        end
        sheet1[pos,column+=1] = text
      else
        sheet1[pos,column+=1] = ''
      end

      # monitor details
      if equipment_registration.monitors.size > 0
        text = ''
        count = 1
        equipment_registration.monitors.each do |monitor|
          text += 'Monitor ' + count.to_s + "\n"
          text += 'Screen Size: ' + monitor.monitor_size + "\n" unless monitor.monitor_size.blank?
          text += "\n"
          count += 1
        end
        sheet1[pos,column+=1] = text
      else
        sheet1[pos,column+=1] = ''
      end

      # power strip details
      if equipment_registration.power_strips.size > 0
        text = ''
        count = 1
        equipment_registration.power_strips.each do |power_strip|
          text += 'Power Strip ' + count.to_s + "\n"
          text += 'Make: ' + power_strip.make + "\n" unless power_strip.make.blank?
          text += 'Model: ' + power_strip.model + "\n" unless power_strip.model.blank?
          text += 'Color: ' + power_strip.color + "\n" unless power_strip.color.blank?
          text += 'Number Of Plugs: ' + power_strip.number_of_plugs + "\n" unless power_strip.number_of_plugs.blank?
          text += "\n"
          count += 1
        end
        sheet1[pos,column+=1] = text
      else
        sheet1[pos,column+=1] = ''
      end

      # extension cord details
      if equipment_registration.extension_cords.size > 0
        text = ''
        count = 1
        equipment_registration.extension_cords.each do |extension_cord|
          text += 'Extension Cord ' + count.to_s + "\n"
          text += 'Color: ' + extension_cord.color + "\n" unless extension_cord.color.blank?
          text += 'Length: ' + extension_cord.length + "\n" unless extension_cord.length.blank?
          text += "\n"
          count += 1
        end
        sheet1[pos,column+=1] = text
      else
        sheet1[pos,column+=1] = ''
      end

      sheet1.row(pos).default_format = format
      pos += 1
    end

    for i in 0..17
      sheet1.column(i).width = 25
    end

    book.write "#{RAILS_ROOT}/public/download/equipment_registrations.xls"

    send_file "#{RAILS_ROOT}/public/download/equipment_registrations.xls", :filename => "equipment_registrations.xls"
  end

  # create a downloadable excel of seminar registrations
  def seminar_registrations
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    group_header_format = Spreadsheet::Format.new :weight => :bold, :align => :merge
    header_format = Spreadsheet::Format.new :weight => :bold, :horizontal_align => :left
    format = Spreadsheet::Format.new :horizontal_align => :distributed, :vertical_align => :top

    # write out group headers
    sheet1[0,5] = 'District Issues: Part 1'
    sheet1[0,6] = 'District Issues: Part 2'
    sheet1[0,7] = 'Local Issues: Part 1'
    sheet1[0,8] = 'Local Issues: Part 2'
    sheet1[0,9] = 'Local Issues: Part 3'
    sheet1[0,10] = 'Better Officiating'
    sheet1[0,12] = 'Discipling Part 1 (Adults)'
    sheet1[0,13] = 'Discipling Part 2 (Adults)'
    sheet1[0,14] = 'QuizMachine and QMServer'
    sheet1[0,16] = 'Admissions Group 1'
    sheet1[0,17] = 'Admissions Group 2'
    sheet1[0,18] = 'Admissions Group 3'
    sheet1[0,19] = 'Discipling Part 1 (Quizzers)'
    sheet1[0,20] = 'Discipling Part 2 (Quizzers)'
    sheet1[0,21] = 'qUiZ SkIllz (Basic)'
    sheet1[0,23] = 'qUiZ SkIllz (Advanced)'
    sheet1[0,25] = ''
    for i in 5..24
      sheet1.row(0).set_format(i,group_header_format)
    end
    
    # write out headers
    column = 0
    sheet1[1,column] = 'Name'
    sheet1[1,column+=1] = 'Phone'
    sheet1[1,column+=1] = 'Email'
    sheet1[1,column+=1] = 'District'
    sheet1[1,column+=1] = 'Region'
    sheet1[1,column+=1] = 'Tuesday, July 3 - 7:15 pm'
    sheet1[1,column+=1] = 'Friday, July 6 - 7:15 pm'
    sheet1[1,column+=1] = 'Tuesday, July 3 - 7:15 pm'
    sheet1[1,column+=1] = 'Thursday, July 5 - 7:15 pm'
    sheet1[1,column+=1] = 'Friday, July 6 - 7:15 pm'
    sheet1[1,column+=1] = 'Thursday, July 5 - 7:15 pm'
    sheet1[1,column+=1] = 'Friday, July 6 - 7:15 pm'
    sheet1[1,column+=1] = 'Monday, July 2 - 4:00 pm'
    sheet1[1,column+=1] = 'Thursday, July 5 - 7:15 pm'
    sheet1[1,column+=1] = 'Thursday, July 5 - 7:15 pm'
    sheet1[1,column+=1] = 'Saturday, July 7 - 9:00 am'
    sheet1[1,column+=1] = 'Tuesday, July 3 - 7:15 pm'
    sheet1[1,column+=1] = 'Friday, July 6 - 7:15 pm'
    sheet1[1,column+=1] = 'Saturday, July 7 - 9:00 am'
    sheet1[1,column+=1] = 'Tuesday, July 3 - 7:15 pm'
    sheet1[1,column+=1] = 'Friday, July 6 - 7:15 pm'
    sheet1[1,column+=1] = 'Monday, July 2 - 4:00 pm'
    sheet1[1,column+=1] = 'Thursday, July 5 - 7:15 pm'
    sheet1[1,column+=1] = 'Monday, July 2 - 4:00 pm'
    sheet1[1,column+=1] = 'Thursday, July 5 - 7:15 pm'
    sheet1.row(1).default_format = header_format

    @seminar_registrations = SeminarRegistration.all(:order => 'last_name asc')

    pos = 2
    seminar_1 = 0
    seminar_2 = 0
    seminar_3 = 0
    seminar_4 = 0
    seminar_5 = 0
    seminar_6_session_1 = 0
    seminar_6_session_2 = 0
    seminar_7 = 0
    seminar_8 = 0
    seminar_9_session_1 = 0
    seminar_9_session_2 = 0
    seminar_10 = 0
    seminar_11 = 0
    seminar_12 = 0
    seminar_13 = 0
    seminar_14 = 0
    seminar_15_session_1 = 0
    seminar_15_session_2 = 0
    seminar_16_session_1 = 0
    seminar_16_session_2 = 0

    @seminar_registrations.each do |seminar_registration|
      column = 0
      sheet1[pos,column] = seminar_registration.full_name
      sheet1[pos,column+=1] = seminar_registration.phone
      sheet1[pos,column+=1] = seminar_registration.email
      sheet1[pos,column+=1] = seminar_registration.district.name
      sheet1[pos,column+=1] = seminar_registration.district.region.name
      sheet1[pos,column+=1] = seminar_registration.seminar_1? ? 'Attending' : ''
      seminar_1 += 1 if seminar_registration.seminar_1?
      sheet1[pos,column+=1] = seminar_registration.seminar_2? ? 'Attending' : ''
      seminar_2 += 1 if seminar_registration.seminar_2?
      sheet1[pos,column+=1] = seminar_registration.seminar_3? ? 'Attending' : ''
      seminar_3 += 1 if seminar_registration.seminar_3?
      sheet1[pos,column+=1] = seminar_registration.seminar_4? ? 'Attending' : ''
      seminar_4 += 1 if seminar_registration.seminar_4?
      sheet1[pos,column+=1] = seminar_registration.seminar_5? ? 'Attending' : ''
      seminar_5 += 1 if seminar_registration.seminar_5?
      sheet1[pos,column+=1] = seminar_registration.seminar_6_session == 'Thursday, July 5 - 7:15 pm' ? 'Attending' : ''
      seminar_6_session_1 += 1 if seminar_registration.seminar_6_session == 'Thursday, July 5 - 7:15 pm'
      sheet1[pos,column+=1] = seminar_registration.seminar_6_session == 'Friday, July 6 - 7:15 pm' ? 'Attending' : ''
      seminar_6_session_2 += 1 if seminar_registration.seminar_6_session == 'Friday, July 6 - 7:15 pm'
      sheet1[pos,column+=1] = seminar_registration.seminar_7? ? 'Attending' : ''
      seminar_7 += 1 if seminar_registration.seminar_7?
      sheet1[pos,column+=1] = seminar_registration.seminar_8? ? 'Attending' : ''
      seminar_8 += 1 if seminar_registration.seminar_8?
      sheet1[pos,column+=1] = seminar_registration.seminar_9_session == 'Thursday, July 5 - 7:15 pm' ? 'Attending' : ''
      seminar_9_session_1 += 1 if seminar_registration.seminar_9_session == 'Thursday, July 5 - 7:15 pm'
      sheet1[pos,column+=1] = seminar_registration.seminar_9_session == 'Saturday, July 7 - 9:00 am' ? 'Attending' : ''
      seminar_9_session_2 += 1 if seminar_registration.seminar_9_session == 'Saturday, July 7 - 9:00 am'
      sheet1[pos,column+=1] = seminar_registration.seminar_10? ? 'Attending' : ''
      seminar_10 += 1 if seminar_registration.seminar_10?
      sheet1[pos,column+=1] = seminar_registration.seminar_11? ? 'Attending' : ''
      seminar_11 += 1 if seminar_registration.seminar_11?
      sheet1[pos,column+=1] = seminar_registration.seminar_12? ? 'Attending' : ''
      seminar_12 += 1 if seminar_registration.seminar_12?
      sheet1[pos,column+=1] = seminar_registration.seminar_14? ? 'Attending' : ''
      seminar_14 += 1 if seminar_registration.seminar_14?
      sheet1[pos,column+=1] = seminar_registration.seminar_13? ? 'Attending' : ''
      seminar_13 += 1 if seminar_registration.seminar_13?
      sheet1[pos,column+=1] = seminar_registration.seminar_15_session == 'Monday, July 2 - 4:00 pm' ? 'Attending' : ''
      seminar_15_session_1 += 1 if seminar_registration.seminar_15_session == 'Monday, July 2 - 4:00 pm'
      sheet1[pos,column+=1] = seminar_registration.seminar_15_session == 'Thursday, July 5 - 7:15 pm' ? 'Attending' : ''
      seminar_15_session_2 += 1 if seminar_registration.seminar_15_session == 'Thursday, July 5 - 7:15 pm'
      sheet1[pos,column+=1] = seminar_registration.seminar_16_session == 'Monday, July 2 - 4:00 pm' ? 'Attending' : ''
      seminar_16_session_1 += 1 if seminar_registration.seminar_16_session == 'Monday, July 2 - 4:00 pm'
      sheet1[pos,column+=1] = seminar_registration.seminar_16_session == 'Thursday, July 5 - 7:15 pm' ? 'Attending' : ''
      seminar_16_session_2 += 1 if seminar_registration.seminar_16_session == 'Thursday, July 5 - 7:15 pm'

      sheet1.row(pos).default_format = format
      pos += 1
    end

    # ourput totals
    column = 4
    sheet1[pos,column] = 'Totals'
    sheet1[pos,column+=1] = seminar_1
    sheet1[pos,column+=1] = seminar_2
    sheet1[pos,column+=1] = seminar_3
    sheet1[pos,column+=1] = seminar_4
    sheet1[pos,column+=1] = seminar_5
    sheet1[pos,column+=1] = seminar_6_session_1
    sheet1[pos,column+=1] = seminar_6_session_2
    sheet1[pos,column+=1] = seminar_7
    sheet1[pos,column+=1] = seminar_8
    sheet1[pos,column+=1] = seminar_9_session_1
    sheet1[pos,column+=1] = seminar_9_session_2
    sheet1[pos,column+=1] = seminar_10
    sheet1[pos,column+=1] = seminar_11
    sheet1[pos,column+=1] = seminar_12
    sheet1[pos,column+=1] = seminar_13
    sheet1[pos,column+=1] = seminar_14
    sheet1[pos,column+=1] = seminar_15_session_1
    sheet1[pos,column+=1] = seminar_15_session_2
    sheet1[pos,column+=1] = seminar_16_session_1
    sheet1[pos,column+=1] = seminar_16_session_2

    for i in 0..26
      sheet1.column(i).width = 30
    end

    book.write "#{RAILS_ROOT}/public/download/seminar_registrations.xls"

    send_file "#{RAILS_ROOT}/public/download/seminar_registrations.xls", :filename => "seminar_registrations.xls"
  end

  # housing report by building
  # produces an excel document for download based upon the passed in building_id
  # if no building id is passed in then we produce an excel document with all
  # buildings with one building per tab.
  def housing_by_building
    book = Spreadsheet::Workbook.new

    if (!params['building_id'].blank?)
      sheet1 = book.create_worksheet

      building = Building.find(params[:building_id])
      participants = ParticipantRegistration.by_building(params[:building_id]).ordered_by_room

      # formatting
      title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
      header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

      # write out title
      sheet1[0,0] = 'Housing By Building: ' + building.name
      sheet1.row(0).set_format(0,title_format)

      # write out headers
      column = 0
      sheet1[1,column] = 'Room'
      sheet1[1,column+=1] = 'Key Code'
      sheet1[1,column+=1] = 'Participant'
      sheet1[1,column+=1] = 'Gender'
      sheet1[1,column+=1] = 'Role'
      sheet1[1,column+=1] = 'Age Group / Grade'
      sheet1[1,column+=1] = 'District'
      sheet1[1,column+=1] = 'Region'
      sheet1[1,column+=1] = 'Group Leader'
      sheet1[1,column+=1] = 'July 1st'
      sheet1[1,column+=1] = 'July 7th'
      sheet1.row(1).default_format = header_format

      pos = 2
      participants.each do |participant|
        column = 0
        sheet1[pos,column] = participant.room
        sheet1[pos,column+=1] = participant.keycode
        sheet1[pos,column+=1] = participant.full_name_reversed
        sheet1[pos,column+=1] = participant.gender
        sheet1[pos,column+=1] = participant.formatted_registration_type
        sheet1[pos,column+=1] = participant.most_recent_grade
        sheet1[pos,column+=1] = participant.district.name
        sheet1[pos,column+=1] = participant.district.region.name

        # group leader
        if (participant.group_leader == '-1')
          group_leader_name = 'Group Leader Not Listed'
        elsif (participant.group_leader == '-2')
          group_leader_name = 'Group Leader Not Known'
        elsif (participant.group_leader == '-3')
          group_leader_name = 'No Group Leader'
        elsif (participant.group_leader == '-4')
          group_leader_name = 'Staff'
        elsif (participant.group_leader == '-5')
          group_leader_name = 'Official'
        elsif (participant.group_leader == '-6')
          group_leader_name = 'Volunteer'
        else
          user = User.find(participant.group_leader)
          group_leader_name = user.fullname
        end
        sheet1[pos,column+=1] = group_leader_name

        sheet1[pos,column+=1] = participant.bought_extra?('housing_sunday') ? 'Yes' : ''
        sheet1[pos,column+=1] = participant.bought_extra?('housing_saturday') ? 'Yes' : ''

        pos += 1
      end

      sheet1.column(2).width = 25
      sheet1.column(5).width = 25
      sheet1.column(6).width = 25
      sheet1.column(7).width = 25
      sheet1.column(8).width = 25

      file_name = building.name.downcase

      book.write "#{RAILS_ROOT}/public/download/housing_by_building_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/housing_by_building_#{file_name}.xls", :filename => "housing_by_building_#{file_name}.xls"
    else
      file_name = 'all'
      buildings = Building.all(:order => 'name asc')

      buildings.each do |building|
        sheet1 = book.create_worksheet
        participants = ParticipantRegistration.by_building(building.id).ordered_by_room

        # formatting
        title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
        header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

        # write out title
        sheet1[0,0] = 'Housing By Building: ' + building.name
        sheet1.row(0).set_format(0,title_format)

        # write out headers
        column = 0
        sheet1[1,column] = 'Room'
        sheet1[1,column+=1] = 'Key Code'
        sheet1[1,column+=1] = 'Participant'
        sheet1[1,column+=1] = 'Gender'
        sheet1[1,column+=1] = 'Role'
        sheet1[1,column+=1] = 'Age Group / Grade'
        sheet1[1,column+=1] = 'District'
        sheet1[1,column+=1] = 'Region'
        sheet1[1,column+=1] = 'Group Leader'
        sheet1[1,column+=1] = 'July 1st'
        sheet1[1,column+=1] = 'July 7th'
        sheet1.row(1).default_format = header_format

        pos = 2
        participants.each do |participant|
          column = 0
          sheet1[pos,column] = participant.room
          sheet1[pos,column+=1] = participant.keycode
          sheet1[pos,column+=1] = participant.full_name_reversed
          sheet1[pos,column+=1] = participant.gender
          sheet1[pos,column+=1] = participant.formatted_registration_type
          sheet1[pos,column+=1] = participant.most_recent_grade
          sheet1[pos,column+=1] = participant.district.name
          sheet1[pos,column+=1] = participant.district.region.name

          # group leader
          if (participant.group_leader == '-1')
            group_leader_name = 'Group Leader Not Listed'
          elsif (participant.group_leader == '-2')
            group_leader_name = 'Group Leader Not Known'
          elsif (participant.group_leader == '-3')
            group_leader_name = 'No Group Leader'
          elsif (participant.group_leader == '-4')
            group_leader_name = 'Staff'
          elsif (participant.group_leader == '-5')
            group_leader_name = 'Official'
          elsif (participant.group_leader == '-6')
            group_leader_name = 'Volunteer'
          else
            user = User.find(participant.group_leader)
            group_leader_name = user.fullname
          end
          sheet1[pos,column+=1] = group_leader_name

          sheet1[pos,column+=1] = participant.bought_extra?('housing_sunday') ? 'Yes' : ''
          sheet1[pos,column+=1] = participant.bought_extra?('housing_saturday') ? 'Yes' : ''

          pos += 1
        end

        sheet1.column(2).width = 25
        sheet1.column(5).width = 25
        sheet1.column(6).width = 25
        sheet1.column(7).width = 25
        sheet1.column(8).width = 25

        sheet1.name = building.name
      end

      book.write "#{RAILS_ROOT}/public/download/housing_by_building_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/housing_by_building_#{file_name}.xls", :filename => "housing_by_building_#{file_name}.xls"
    end
  end

  # housing report by group leader
  # produces an excel document for download based upon the passed in group leader id
  # if no group leader id is passed in then we produce an excel document with all
  # group leaders with one group leader per tab.
  def housing_by_group_leader
    book = Spreadsheet::Workbook.new

    if (!params['group_leader'].blank?)
      sheet1 = book.create_worksheet

      if (params['group_leader'] == '-1')
        group_leader_name = 'Group Leader Not Listed'
        file_name = 'group_leader_not_listed'
        participants = ParticipantRegistration.by_group_leader(-1).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-2')
        group_leader_name = 'Group Leader Not Known'
        file_name = 'group_leader_not_known'
        participants = ParticipantRegistration.by_group_leader(-2).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-3')
        group_leader_name = 'No Group Leader'
        file_name = 'no_group_leader'
        participants = ParticipantRegistration.by_group_leader(-3).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-4')
        group_leader_name = 'Staff'
        file_name = 'staff'
        participants = ParticipantRegistration.by_group_leader(-4).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-5')
        group_leader_name = 'Official'
        file_name = 'official'
        participants = ParticipantRegistration.by_group_leader(-5).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-6')
        group_leader_name = 'Volunteer'
        file_name = 'volunteer'
        participants = ParticipantRegistration.by_group_leader(-6).ordered_by_building_room_last_name
      else
        group_leader = User.find(params['group_leader'])
        group_leader_name = group_leader.fullname
        file_name = (group_leader.first_name + '_' + group_leader.last_name).downcase
        participants = ParticipantRegistration.by_group_leader(params['group_leader']).ordered_by_building_room_last_name
      end

      # formatting
      title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
      header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

      # write out title
      sheet1[0,0] = 'Housing By Group Leader: ' + group_leader_name
      sheet1.row(0).set_format(0,title_format)

      # write out headers
      column = 0
      sheet1[1,column] = 'Building'
      sheet1[1,column+=1] = 'Room'
      sheet1[1,column+=1] = 'Key Code'
      sheet1[1,column+=1] = 'Participant'
      sheet1[1,column+=1] = 'Gender'
      sheet1[1,column+=1] = 'Role'
      sheet1[1,column+=1] = 'Age Group / Grade'
      sheet1[1,column+=1] = 'District'
      sheet1[1,column+=1] = 'Region'
      sheet1[1,column+=1] = 'July 1st'
      sheet1[1,column+=1] = 'July 7th'
      sheet1.row(1).default_format = header_format

      pos = 2
      participants.each do |participant|
        column = 0
        sheet1[pos,column] = !participant.building.blank? ? participant.building.name : ''
        sheet1[pos,column+=1] = !participant.room.blank? ? participant.room : ''
        sheet1[pos,column+=1] = participant.keycode
        sheet1[pos,column+=1] = participant.full_name_reversed
        sheet1[pos,column+=1] = participant.gender
        sheet1[pos,column+=1] = participant.formatted_registration_type
        sheet1[pos,column+=1] = participant.most_recent_grade
        sheet1[pos,column+=1] = participant.district.name
        sheet1[pos,column+=1] = participant.district.region.name
        sheet1[pos,column+=1] = participant.bought_extra?('housing_sunday') ? 'Yes' : ''
        sheet1[pos,column+=1] = participant.bought_extra?('housing_saturday') ? 'Yes' : ''

        pos += 1
      end

      sheet1.column(0).width = 20
      sheet1.column(3).width = 25
      sheet1.column(6).width = 20
      sheet1.column(7).width = 25
      sheet1.column(8).width = 25

      book.write "#{RAILS_ROOT}/public/download/housing_by_group_leader_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/housing_by_group_leader_#{file_name}.xls", :filename => "housing_by_building_#{file_name}.xls"
    else
      file_name = 'all'

      # loop through all group leaders
      group_leaders = User.find(:all, :joins => [:team_registrations], :conditions => "team_registrations.paid = 1", :order => "first_name,last_name").map { |user| user.id }.uniq
      group_leaders.push(-1)
      group_leaders.push(-2)
      group_leaders.push(-3)
      group_leaders.push(-4)
      group_leaders.push(-5)
      group_leaders.push(-6)

      group_leaders.each do |leader|
        sheet1 = book.create_worksheet

        if (leader == -1)
          group_leader_name = 'Group Leader Not Listed'
          participants = ParticipantRegistration.by_group_leader(-1).ordered_by_building_room_last_name
        elsif (leader == -2)
          group_leader_name = 'Group Leader Not Known'
          participants = ParticipantRegistration.by_group_leader(-2).ordered_by_building_room_last_name
        elsif (leader == -3)
          group_leader_name = 'No Group Leader'
          participants = ParticipantRegistration.by_group_leader(-3).ordered_by_building_room_last_name
        elsif (leader == -4)
          group_leader_name = 'Staff'
          participants = ParticipantRegistration.by_group_leader(-4).ordered_by_building_room_last_name
        elsif (leader == -5)
          group_leader_name = 'Official'
          participants = ParticipantRegistration.by_group_leader(-5).ordered_by_building_room_last_name
        elsif (leader == -6)
          group_leader_name = 'Volunteer'
          participants = ParticipantRegistration.by_group_leader(-6).ordered_by_building_room_last_name
        else
          user = User.find(leader)
          group_leader_name = user.fullname
          participants = ParticipantRegistration.by_group_leader(leader).ordered_by_building_room_last_name
        end

        # formatting
        title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
        header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

        # write out title
        sheet1[0,0] = 'Housing By Group Leader: ' + group_leader_name
        sheet1.row(0).set_format(0,title_format)

        # write out headers
        column = 0
        sheet1[1,column] = 'Building'
        sheet1[1,column+=1] = 'Room'
        sheet1[1,column+=1] = 'Key Code'
        sheet1[1,column+=1] = 'Participant'
        sheet1[1,column+=1] = 'Gender'
        sheet1[1,column+=1] = 'Role'
        sheet1[1,column+=1] = 'Age Group / Grade'
        sheet1[1,column+=1] = 'District'
        sheet1[1,column+=1] = 'Region'
        sheet1[1,column+=1] = 'July 1st'
        sheet1[1,column+=1] = 'July 7th'
        sheet1.row(1).default_format = header_format

        pos = 2
        participants.each do |participant|
          column = 0
          sheet1[pos,column] = !participant.building.blank? ? participant.building.name : ''
          sheet1[pos,column+=1] = !participant.room.blank? ? participant.room : ''
          sheet1[pos,column+=1] = participant.keycode
          sheet1[pos,column+=1] = participant.full_name_reversed
          sheet1[pos,column+=1] = participant.gender
          sheet1[pos,column+=1] = participant.formatted_registration_type
          sheet1[pos,column+=1] = participant.most_recent_grade
          sheet1[pos,column+=1] = participant.district.name
          sheet1[pos,column+=1] = participant.district.region.name
          sheet1[pos,column+=1] = participant.bought_extra?('housing_sunday') ? 'Yes' : ''
          sheet1[pos,column+=1] = participant.bought_extra?('housing_saturday') ? 'Yes' : ''

          pos += 1
        end

        sheet1.column(0).width = 20
        sheet1.column(3).width = 25
        sheet1.column(6).width = 20
        sheet1.column(7).width = 25
        sheet1.column(8).width = 25

        sheet1.name = group_leader_name
      end

      book.write "#{RAILS_ROOT}/public/download/housing_by_group_leader_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/housing_by_group_leader_#{file_name}.xls", :filename => "housing_by_group_leader_#{file_name}.xls"
    end
  end

  # ministry project assignment report
  # produces an excel document for download based upon the passed in ministry_project_id
  # if no ministry_project_id is passed in then we produce an excel document with all
  # ministry projects with one ministry project per tab.
  def ministry_projects
    book = Spreadsheet::Workbook.new

    if (!params['ministry_project_id'].blank?)
      sheet1 = book.create_worksheet

      ministry_project = MinistryProject.find(params[:ministry_project_id])
      participants = ParticipantRegistration.by_ministry_project(params[:ministry_project_id]).ordered_by_last_name

      # formatting
      title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
      header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

      # write out title
      sheet1[0,0] = 'MInistry Project: ' + ministry_project.name
      sheet1.row(0).set_format(0,title_format)

      # write out headers
      column = 0
      sheet1[1,column] = 'Group'
      sheet1[1,column+=1] = 'Participant'
      sheet1[1,column+=1] = 'Gender'
      sheet1[1,column+=1] = 'Role'
      sheet1[1,column+=1] = 'Age Group / Grade'
      sheet1[1,column+=1] = 'District'
      sheet1[1,column+=1] = 'Region'
      sheet1[1,column+=1] = 'Group Leader'
      sheet1.row(1).default_format = header_format

      pos = 2
      participants.each do |participant|
        column = 0
        sheet1[pos,column] = participant.ministry_project_group
        sheet1[pos,column+=1] = participant.full_name_reversed
        sheet1[pos,column+=1] = participant.gender
        sheet1[pos,column+=1] = participant.formatted_registration_type
        sheet1[pos,column+=1] = participant.most_recent_grade
        sheet1[pos,column+=1] = participant.district.name
        sheet1[pos,column+=1] = participant.district.region.name

        # group leader
        if (participant.group_leader == '-1')
          group_leader_name = 'Group Leader Not Listed'
        elsif (participant.group_leader == '-2')
          group_leader_name = 'Group Leader Not Known'
        elsif (participant.group_leader == '-3')
          group_leader_name = 'No Group Leader'
        elsif (participant.group_leader == '-4')
          group_leader_name = 'Staff'
        elsif (participant.group_leader == '-5')
          group_leader_name = 'Official'
        elsif (participant.group_leader == '-6')
          group_leader_name = 'Volunteer'
        else
          user = User.find(participant.group_leader)
          group_leader_name = user.fullname
        end
        sheet1[pos,column+=1] = group_leader_name

        pos += 1
      end

      sheet1.column(1).width = 25
      sheet1.column(4).width = 15
      sheet1.column(5).width = 25
      sheet1.column(6).width = 25
      sheet1.column(7).width = 25

      file_name = ministry_project.name.downcase.gsub(/(\s)+/, '_')

      book.write "#{RAILS_ROOT}/public/download/ministry_project_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/ministry_project_#{file_name}.xls", :filename => "ministry_project_#{file_name}.xls"
    else
      file_name = 'all'
      ministry_projects = MinistryProject.all(:order => 'name asc')

      ministry_projects.each do |ministry_project|
        sheet1 = book.create_worksheet
        participants = ParticipantRegistration.by_ministry_project(ministry_project.id).ordered_by_last_name

        # formatting
        title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
        header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

        # write out title
        sheet1[0,0] = 'Ministry Project: ' + ministry_project.name
        sheet1.row(0).set_format(0,title_format)

        # write out headers
        column = 0
        sheet1[1,column] = 'Group'
        sheet1[1,column+=1] = 'Participant'
        sheet1[1,column+=1] = 'Gender'
        sheet1[1,column+=1] = 'Role'
        sheet1[1,column+=1] = 'Age Group / Grade'
        sheet1[1,column+=1] = 'District'
        sheet1[1,column+=1] = 'Region'
        sheet1[1,column+=1] = 'Group Leader'
        sheet1.row(1).default_format = header_format

        pos = 2
        participants.each do |participant|
          column = 0
          sheet1[pos,column] = participant.ministry_project_group
          sheet1[pos,column+=1] = participant.full_name_reversed
          sheet1[pos,column+=1] = participant.gender
          sheet1[pos,column+=1] = participant.formatted_registration_type
          sheet1[pos,column+=1] = participant.most_recent_grade
          sheet1[pos,column+=1] = participant.district.name
          sheet1[pos,column+=1] = participant.district.region.name

          # group leader
          if (participant.group_leader == '-1')
            group_leader_name = 'Group Leader Not Listed'
          elsif (participant.group_leader == '-2')
            group_leader_name = 'Group Leader Not Known'
          elsif (participant.group_leader == '-3')
            group_leader_name = 'No Group Leader'
          elsif (participant.group_leader == '-4')
            group_leader_name = 'Staff'
          elsif (participant.group_leader == '-5')
            group_leader_name = 'Official'
          elsif (participant.group_leader == '-6')
            group_leader_name = 'Volunteer'
          else
            user = User.find(participant.group_leader)
            group_leader_name = user.fullname
          end
          sheet1[pos,column+=1] = group_leader_name

          pos += 1
        end

        sheet1.column(1).width = 25
        sheet1.column(4).width = 10
        sheet1.column(5).width = 25
        sheet1.column(6).width = 25
        sheet1.column(7).width = 25

        sheet1.name = ministry_project.name
      end

      book.write "#{RAILS_ROOT}/public/download/ministry_project_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/ministry_project_#{file_name}.xls", :filename => "ministry_project_#{file_name}.xls"
    end
  end

  # create a downloadable excel of participants and their liability form status
  def participants_liability
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Name'
    sheet1[0,column+=1] = 'Home Phone'
    sheet1[0,column+=1] = 'Mobile Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Region'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'Liability Form'
    sheet1.row(0).default_format = header_format

    if params[:received]
      @participants = ParticipantRegistration.medical_liability_complete.ordered_by_last_name
      file_name = 'received'
    elsif params[:not_received]
      @participants = ParticipantRegistration.medical_liability_incomplete.ordered_by_last_name
      file_name = 'not_received'
    else
      @participants = ParticipantRegistration.ordered_by_last_name
      file_name = 'all'
    end

    pos = 1
    @participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.mobile_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = participant.district.name
      sheet1[pos,column+=1] = participant.district.region.name

      # group leader
      if (participant.group_leader == '-1')
        group_leader_name = 'Group Leader Not Listed'
      elsif (participant.group_leader == '-2')
        group_leader_name = 'Group Leader Not Known'
      elsif (participant.group_leader == '-3')
        group_leader_name = 'No Group Leader'
      elsif (participant.group_leader == '-4')
        group_leader_name = 'Staff'
      elsif (participant.group_leader == '-5')
        group_leader_name = 'Official'
      elsif (participant.group_leader == '-6')
        group_leader_name = 'Volunteer'
      else
        user = User.find(participant.group_leader)
        group_leader_name = user.fullname
      end
      sheet1[pos,column+=1] = group_leader_name

      sheet1[pos,column+=1] = participant.medical_liability? ? 'Recieved' : 'Not Received'

      pos += 1
    end

    for i in 0..7
      sheet1.column(i).width = 20
    end
    sheet1.column(3).width = 30

    book.write "#{RAILS_ROOT}/public/download/participants_liability_#{file_name}.xls"

    send_file "#{RAILS_ROOT}/public/download/participants_liability_#{file_name}.xls", :filename => "participants_liability_#{file_name}.xls"
  end

  # create a downloadable excel of quizzers and coaches that don't have a team
  def no_team
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Name'
    sheet1[0,column+=1] = 'Role'
    sheet1[0,column+=1] = 'Home Phone'
    sheet1[0,column+=1] = 'Mobile Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Region'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1.row(0).default_format = header_format

    @participants = ParticipantRegistration.all(:conditions => "(registration_type = 'quizzer' or registration_type = 'coach') and (team1_id = '' or team1_id is null) and (team2_id = '' or team2_id is null) and (team3_id = '' or team3_id is null)")

    pos = 1
    @participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.formatted_registration_type
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.mobile_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = participant.district.name
      sheet1[pos,column+=1] = participant.district.region.name

      # group leader
      if (participant.group_leader == '-1')
        group_leader_name = 'Group Leader Not Listed'
      elsif (participant.group_leader == '-2')
        group_leader_name = 'Group Leader Not Known'
      elsif (participant.group_leader == '-3')
        group_leader_name = 'No Group Leader'
      elsif (participant.group_leader == '-4')
        group_leader_name = 'Staff'
      elsif (participant.group_leader == '-5')
        group_leader_name = 'Official'
      elsif (participant.group_leader == '-6')
        group_leader_name = 'Volunteer'
      else
        user = User.find(participant.group_leader)
        group_leader_name = user.fullname
      end
      sheet1[pos,column+=1] = group_leader_name

      pos += 1
    end

    for i in 0..6
      sheet1.column(i).width = 20
    end
    sheet1.column(4).width = 30

    book.write "#{RAILS_ROOT}/public/download/no_team.xls"

    send_file "#{RAILS_ROOT}/public/download/no_team.xls", :filename => "no_team.xls"
  end

  # create a downloadable excel file of ministry projects on one sheet
  def ministry_projects_full
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Participant'
    sheet1[0,column+=1] = 'Ministry Project'
    sheet1[0,column+=1] = 'Group'
    sheet1[0,column+=1] = 'Gender'
    sheet1[0,column+=1] = 'Role'
    sheet1[0,column+=1] = 'Age Group / Grade'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Region'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.ordered_by_last_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = !participant.ministry_project.blank? ? participant.ministry_project.name : ''
      sheet1[pos,column+=1] = !participant.ministry_project_group.blank? ? participant.ministry_project_group : ''
      sheet1[pos,column+=1] = participant.gender
      sheet1[pos,column+=1] = participant.formatted_registration_type
      sheet1[pos,column+=1] = participant.most_recent_grade
      sheet1[pos,column+=1] = participant.district.name
      sheet1[pos,column+=1] = participant.district.region.name
      sheet1[pos,column+=1] = participant.group_leader_name

      pos += 1
    end

    # column widths
    sheet1.column(0).width = 25
    sheet1.column(1).width = 25
    sheet1.column(5).width = 20
    sheet1.column(6).width = 25
    sheet1.column(7).width = 25
    sheet1.column(8).width = 25

    book.write "#{RAILS_ROOT}/public/download/ministry_projects_full.xls"

    send_file "#{RAILS_ROOT}/public/download/ministry_projects_full.xls", :filename => "ministry_projects_full.xls"
  end

  # create a downloadable excel file of all housing on one sheet
  def housing_all
    @filename = 'all'
    housing
  end

  # create a downloadable excel file of pre / post housing on one sheet
  def housing_pre_post
    @only_pre_post = true
    @filename = 'pre_post'
    housing
  end

  # create a downloadable excel file of housing on one sheet
  # depending on various params we either provide all assignments or a subset
  # this method should not be called directly
  def housing
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Building'
    sheet1[0,column+=1] = 'Room'
    sheet1[0,column+=1] = 'Key Code'
    sheet1[0,column+=1] = 'Participant'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Pre (July 1st)'
    sheet1[0,column+=1] = 'Post (July 7th)'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.ordered_by_last_name

    pos = 1
    participants.each do |participant|
      if @only_pre_post && !participant.bought_extra?('housing_sunday') && !participant.bought_extra?('housing_saturday')
        next
      end

      column = 0
      sheet1[pos,column] = !participant.building.blank? ? participant.building.name : ''
      sheet1[pos,column+=1] = !participant.room.blank? ? participant.room : ''
      sheet1[pos,column+=1] = participant.keycode
      sheet1[pos,column+=1] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.group_leader_name
      sheet1[pos,column+=1] = participant.district.name
      sheet1[pos,column+=1] = participant.bought_extra?('housing_sunday') ? 'Yes' : ''
      sheet1[pos,column+=1] = participant.bought_extra?('housing_saturday') ? 'Yes' : ''
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 20
    sheet1.column(1).width = 10
    sheet1.column(2).width = 10
    sheet1.column(3).width = 25
    sheet1.column(4).width = 25
    sheet1.column(5).width = 25
    sheet1.column(6).width = 15
    sheet1.column(7).width = 15

    book.write "#{RAILS_ROOT}/public/download/housing_#{@filename}.xls"

    send_file "#{RAILS_ROOT}/public/download/housing_#{@filename}.xls", :filename => "housing_#{@filename}.xls"
  end

  # create a downloadable excel file of participant with special needs
  def special_needs
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Participant'
    sheet1[0,column+=1] = 'Gender'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Special Need'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.has_special_needs.ordered_by_last_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.gender
      sheet1[pos,column+=1] = participant.group_leader_name
      sheet1[pos,column+=1] = participant.district.name
      sheet1[pos,column+=1] = participant.special_needs_details
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 25
    sheet1.column(1).width = 10
    sheet1.column(2).width = 25
    sheet1.column(3).width = 25
    sheet1.column(4).width = 100

    book.write "#{RAILS_ROOT}/public/download/special_needs.xls"

    send_file "#{RAILS_ROOT}/public/download/special_needs.xls", :filename => "special_needs.xls"
  end

  # create a downloadable excel file of core staff members
  def core_staff
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Name'
    sheet1[0,column+=1] = 'Mobile Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.by_registration_type('core_staff').ordered_by_last_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.mobile_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = participant.district.name
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 25
    sheet1.column(1).width = 15
    sheet1.column(2).width = 30
    sheet1.column(3).width = 25

    book.write "#{RAILS_ROOT}/public/download/core_staff.xls"

    send_file "#{RAILS_ROOT}/public/download/core_staff.xls", :filename => "core_staff.xls"
  end

  # create a downloadable excel file of housing and meals on one sheet
  # depending on various params we either provide all participants or a subset
  def housing_meals
    unless params[:report].blank?
      @report = params[:report]
    else
      @report = 'all'
    end

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Housing?'
    sheet1[0,column+=1] = 'Meals?'
    sheet1[0,column+=1] = 'Participant'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Housing Location'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.ordered_by_last_name

    pos = 1
    participants.each do |participant|
      # conditionals
      if @report == 'both' and (!participant.needs_housing? or !participant.needs_meals?)
        next
      end

      if @report == 'housing' and !participant.needs_housing?
        next
      end

      if @report == 'meals' and !participant.needs_meals?
        next
      end

      if @report == 'only_housing' and (!participant.needs_housing? or participant.needs_meals?)
        next
      end

      if @report == 'only_meals' and (participant.needs_housing? or !participant.needs_meals?)
        next
      end

      if @report == 'no_housing' and participant.needs_housing?
        next
      end

      if @report == 'no_meals' and participant.needs_meals?
        next
      end

      if @report == 'neither' and (participant.needs_housing? or participant.needs_meals?)
        next
      end

      column = 0
      sheet1[pos,column] = participant.needs_housing? ? 'YES' : ''
      sheet1[pos,column+=1] = participant.needs_meals? ? 'YES' : ''
      sheet1[pos,column+=1] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.group_leader_name
      sheet1[pos,column+=1] = participant.district.name
      
      # housing
      if !participant.building.nil? or !participant.room.blank?
        assignment = ''
        assignment += participant.building ? participant.building.name : ''
        assignment += !participant.room.blank? ? ' - ' + participant.room : ''
        sheet1[pos,column+=1] = assignment
      else
        sheet1[pos,column+=1] = ''
      end

      pos += 1
    end

    # column widths
    sheet1.column(0).width = 10
    sheet1.column(1).width = 10
    sheet1.column(2).width = 25
    sheet1.column(3).width = 25
    sheet1.column(4).width = 25
    sheet1.column(5).width = 30

    book.write "#{RAILS_ROOT}/public/download/housing_meals_#{@report}.xls"

    send_file "#{RAILS_ROOT}/public/download/housing_meals_#{@report}.xls", :filename => "housing_meals_#{@report}.xls"
  end
end