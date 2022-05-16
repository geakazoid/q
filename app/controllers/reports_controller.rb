class ReportsController < ApplicationController
  require "spreadsheet"
  require_role ['admin','housing_admin','seminar_admin','ministry_project_admin','equipment_admin'], :except => :group_leader_summary

  # GET /reports
  # lists all available reports
  def index
    # populate events list for selecting an event
    @selected_event = params[:event_id] ? params[:event_id] : Event.active_event.id
    @events = Event.get_events

    # populate group leaders
    @group_leaders1 = User.find(:all, :joins => [:participant_registrations], :conditions => "event_id = #{@selected_event} and (num_novice_district_teams > 0 or num_experienced_district_teams > 0 or num_novice_local_teams > 0 or num_experienced_local_teams > 0)", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    @group_leaders2 = User.find(:all, :joins => [:team_registrations], :conditions => "event_id = #{@selected_event}", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    @group_leaders = @group_leaders1 + @group_leaders2
    @group_leaders = @group_leaders.uniq.sort_by { |user| user[0].downcase }
    @group_leaders.push(['Staff', -4])
    @group_leaders.push(['Official', -5])
    @group_leaders.push(['Volunteer', -6])
    @group_leaders.push(['Representative', -7])
    @group_leaders.push(['Group Leader Not Listed', -1])
    @group_leaders.push(['Group Leader Not Known', -2])
    @group_leaders.push(['No Group Leader', -3])

    # populate buildings
    @buildings = Building.all(:conditions => "event_id = #{@selected_event}")

    # populate ministry projects
    @ministry_projects = MinistryProject.all(:conditions => "event_id = #{@selected_event}")
  end
  
  # generate a report of all team registrations
  def team_registrations_all
    @team_registrations = TeamRegistration.all(:conditions => "event_id = #{params['event_id']}")
    @report_type = 'all'
    team_registrations
  end

  # generate a report of all paid team registrations
  def team_registrations_paid
    @team_registrations = TeamRegistration.all(:conditions => "event_id = #{params['event_id']} and paid = 1")
    @report_type = 'paid'
    team_registrations
  end

  # generate a report of all unpaid team registrations
  def team_registrations_unpaid
    @team_registrations = TeamRegistration.all(:conditions => "event_id = #{params['event_id']} and paid = 0")
    @report_type = 'unpaid'
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
    sheet1[0,7] = 'Field'
    sheet1[0,8] = 'Paid?'
    sheet1[0,9] = 'Registration Time'

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
        sheet1[pos,8] = team_registration.paid? ? 'YES' : 'NO'
        sheet1[pos,9] = team_registration.created_at.strftime("%m/%d/%Y %H:%M:%S")
        pos = pos + 1
      end
    end
    book.write "#{RAILS_ROOT}/public/download/team_registrations_#{@report_type}.xls"

    send_file "#{RAILS_ROOT}/public/download/team_registrations_#{@report_type}.xls", :filename => "team_registrations_#{@report_type}.xls"
  end

  # generate a report of all participant registrations
  def participant_registrations_all
    @participant_registrations = ParticipantRegistration.all(:order => 'last_name asc, first_name asc', :conditions => "event_id = #{params['event_id']}")
    @report_type = 'all'
    participant_registrations
  end

  # generate a report participant registrationsa staying off campus
  def participant_registrations_off_campus
    @participant_registrations = ParticipantRegistration.all(:order => 'last_name asc, first_name asc', :conditions => "registration_type = 'off-campus' and event_id = #{params['event_id']}")
    @report_type = 'staying_off_campus'
    participant_registrations
  end

  # generate a report of paid participant registrations
  def participant_registrations_paid
    @participant_registrations = ParticipantRegistration.all(:order => 'last_name asc, first_name asc', :conditions => "event_id = #{params['event_id']} and paid = 1")
    @report_type = 'paid'
    participant_registrations
  end

  # generate a report of unpaid participant registrations
  def participant_registrations_unpaid
    @participant_registrations = ParticipantRegistration.all(:order => 'last_name asc, first_name asc', :conditions => "event_id = #{params['event_id']} and paid = 0")
    @report_type = 'unpaid'
    participant_registrations
  end

  # generate a report of registrations that have the off campus discount
  def participant_registrations_offcampus_discount
    registrations = ParticipantRegistration.all(:order => 'last_name asc, first_name asc', :conditions => "event_id = #{params['event_id']} and paid = 1")
    @report_type = 'offcampus_discount'

    @participant_registrations = Array.new
    offcampus_discount = RegistrationOption.find_by_item('Off-Campus Housing Discount')
    registrations.each do |registration|
      if (registration.registration_options.include?(offcampus_discount))
        @participant_registrations.push(registration)
      end
    end
    participant_registrations
  end

  # create a downloadable excel file of participant registrations
  # this method should not be accessed directly
  def participant_registrations

    registration_options_meals = RegistrationOption.all(:conditions => 'category = "meal"', :order => 'sort')
    registration_options_other = RegistrationOption.all(:conditions => 'category = "other"', :order => 'sort')

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
    sheet1[0,column+=1] = 'Country'
    sheet1[0,column+=1] = 'Gender'
    sheet1[0,column+=1] = 'Age / Most Recent Grade'
    sheet1[0,column+=1] = 'Graduation Year'
    sheet1[0,column+=1] = 'Over 18'
    sheet1[0,column+=1] = 'Primary Phone'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'Local Church'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Field'
    sheet1[0,column+=1] = 'Shirt Size'
    sheet1[0,column+=1] = 'Roommate Preference 1'
    sheet1[0,column+=1] = 'Roommate Preference 2'
    sheet1[0,column+=1] = 'Team 1'
    sheet1[0,column+=1] = 'Team 2'
    sheet1[0,column+=1] = 'Team 3'
    sheet1[0,column+=1] = 'Housing Assignment'
    sheet1[0,column+=1] = 'Special Needs?'
    sheet1[0,column+=1] = 'Special Needs Details'
    sheet1[0,column+=1] = 'Travel Type'
    sheet1[0,column+=1] = 'Travel Details'
    
    # registration options
    registration_options_meals.each do |registration_option|
      sheet1[0,column+=1] = registration_option.item
    end
    registration_options_other.each do |registration_option|
      sheet1[0,column+=1] = registration_option.item
    end

    sheet1[0,column+=1] = 'Medical / Liability?'
    sheet1[0,column+=1] = 'Payment Amount'
    sheet1[0,column+=1] = 'Paid?'
    sheet1[0,column+=1] = 'Created On'
    sheet1[0,column+=1] = 'Updated On'

    pos = 1
    @participant_registrations.each do |participant_registration|
      column = 0
      sheet1[pos,column] = participant_registration.id
      sheet1[pos,column+=1] = participant_registration.formatted_registration_type
      sheet1[pos,column+=1] = participant_registration.full_name
      sheet1[pos,column+=1] = participant_registration.first_name
      sheet1[pos,column+=1] = participant_registration.last_name
      sheet1[pos,column+=1] = participant_registration.email
      sheet1[pos,column+=1] = participant_registration.street
      sheet1[pos,column+=1] = participant_registration.city
      sheet1[pos,column+=1] = participant_registration.state
      sheet1[pos,column+=1] = participant_registration.zipcode
      sheet1[pos,column+=1] = participant_registration.country
      sheet1[pos,column+=1] = participant_registration.gender
      sheet1[pos,column+=1] = participant_registration.most_recent_grade
      sheet1[pos,column+=1] = participant_registration.graduation_year
      sheet1[pos,column+=1] = participant_registration.over_18? ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant_registration.home_phone
      sheet1[pos,column+=1] = participant_registration.group_leader_name
      sheet1[pos,column+=1] = participant_registration.local_church
      if !participant_registration.district.nil?
        sheet1[pos,column+=1] = participant_registration.district.name
      else
        sheet1[pos,column+=1] = ''
      end
      if !participant_registration.district.nil? and !participant_registration.district.region.nil?
        sheet1[pos,column+=1] = participant_registration.district.region.name
      else
        sheet1[pos,column+=1] = ''
      end
      sheet1[pos,column+=1] = participant_registration.shirt_size
      sheet1[pos,column+=1] = participant_registration.roommate_preference_1
      sheet1[pos,column+=1] = participant_registration.roommate_preference_2

      # teams
      if participant_registration.teams.size == 0
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
      elsif participant_registration.teams.size == 1
        sheet1[pos,column+=1] = participant_registration.teams[0].name_with_division
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
      elsif participant_registration.teams.size == 2
        sheet1[pos,column+=1] = participant_registration.teams[0].name_with_division
        sheet1[pos,column+=1] = participant_registration.teams[1].name_with_division
        sheet1[pos,column+=1] = ''
      elsif participant_registration.teams.size == 3
        sheet1[pos,column+=1] = participant_registration.teams[0].name_with_division
        sheet1[pos,column+=1] = participant_registration.teams[1].name_with_division
        sheet1[pos,column+=1] = participant_registration.teams[2].name_with_division
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

      # special needs
      special_needs = ''
      special_needs += 'Food Allergies, ' if participant_registration.special_needs_food_allergies
      special_needs += 'Handicap Accessible, ' if participant_registration.special_needs_handicap_accessible
      special_needs += 'Hearing Impaired, ' if participant_registration.special_needs_hearing_impaired
      special_needs += 'Vision Impaired, ' if participant_registration.special_needs_vision_impaired
      special_needs += 'Other, ' if participant_registration.special_needs_other
      special_needs.chomp(' ,')
      sheet1[pos,column+=1] = special_needs
      sheet1[pos,column+=1] = participant_registration.special_needs_details

      sheet1[pos,column+=1] = participant_registration.travel_type
      sheet1[pos,column+=1] = participant_registration.travel_type_details

      # registration options
      registration_options_meals.each do |registration_option|
        sheet1[pos,column+=1] = participant_registration.registration_options.include?(registration_option) ? "YES" : "NO"
      end
      registration_options_other.each do |registration_option|
        sheet1[pos,column+=1] = participant_registration.registration_options.include?(registration_option) ? "YES" : "NO"
      end

      sheet1[pos,column+=1] = participant_registration.medical_liability? ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant_registration.amount_ordered
      sheet1[pos,column+=1] = participant_registration.paid? ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant_registration.created_at.strftime("%m/%d/%Y %H:%M:%S")
      sheet1[pos,column+=1] = participant_registration.updated_at.strftime("%m/%d/%Y %H:%M:%S")
      pos += 1
    end
    book.write "#{RAILS_ROOT}/public/download/participant_registrations_#{@report_type}.xls"

    send_file "#{RAILS_ROOT}/public/download/participant_registrations_#{@report_type}.xls", :filename => "participant_registrations_#{@report_type}.xls"
  end

  # generate a report of coaches and teams (this only grabs coaches with a paid registration)
  def coaches_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => "registration_type = 'coach' and event_id = #{params['event_id']} and paid = 1", :order => 'last_name asc, first_name asc')
    
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # write out headers
    column = 0
    sheet1[0,column] = 'Participant Name'
    sheet1[0,column+=1] = 'Registration Type'
    sheet1[0,column+=1] = 'Team Name'
    sheet1[0,column+=1] = 'Division'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Field'

    pos = 1
    @participant_registrations.each do |participant_registration|
      participant_registration.coached_teams.each do |team|
        column = 0
        sheet1[pos,column] = participant_registration.full_name
        sheet1[pos,column+=1] = participant_registration.formatted_registration_type
        sheet1[pos,column+=1] = team.name
        sheet1[pos,column+=1] = team.division.name
        sheet1[pos,column+=1] = participant_registration.district.name
        sheet1[pos,column+=1] = participant_registration.district.region.name
        pos += 1
      end
    end

    book.write "#{RAILS_ROOT}/public/download/coaches_teams.xls"

    send_file "#{RAILS_ROOT}/public/download/coaches_teams.xls", :filename => "coaches_teams.xls"
  end

  # generate a report of quizzers and teams (this only grabs quizzers with a paid registration)
  def quizzers_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => "registration_type = 'quizzer' and event_id = #{params['event_id']} and paid = 1", :order => 'last_name asc, first_name asc')
    @report_type = 'quizzers'
    participants_teams
  end

  # create a downloadable excel of quizzers and their team
  def quizmachine
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # write out headers
    column = 0

    @teams = Team.all(:order => 'division_id asc, name asc')

    pos = 1
    @teams.each do |team|
      if !team.team_registration.event_id == params['event_id'] or !team.team_registration.paid?
        next
      end

      team.participant_registrations.each do |quizzer|
        sheet1[pos,0] = team.name
        sheet1[pos,1] = quizzer.full_name
        pos+=1
      end
    end
    
    book.write "#{RAILS_ROOT}/public/download/quizmachine_teams_quizzers.xls"

    send_file "#{RAILS_ROOT}/public/download/quizmachine_teams_quizzers.xls", :filename => "quizmachine_teams_quizzers.xls"
  end

  # create a downloadable excel of participants and teams
  # this method should not be called directly
  def participants_teams
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # write out headers
    column = 0
    sheet1[0,column] = 'Participant Name'
    sheet1[0,column+=1] = 'Registration Type'
    sheet1[0,column+=1] = 'Team Name'
    sheet1[0,column+=1] = 'Division'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Field'

    pos = 1
    @participant_registrations.each do |participant_registration|

      # teams
      if participant_registration.teams.size == 1
        team1 = participant_registration.teams[0]
      elsif participant_registration.teams.size == 2
        team1 = participant_registration.teams[0]
        team2 = participant_registration.teams[1]
      elsif participant_registration.teams.size == 3
        team1 = participant_registration.teams[0]
        team2 = participant_registration.teams[1]
        team3 = participant_registration.teams[2]
      end

      if !team1.nil?
        column = 0
        sheet1[pos,column] = participant_registration.full_name
        sheet1[pos,column+=1] = participant_registration.formatted_registration_type
        sheet1[pos,column+=1] = team1.name
        sheet1[pos,column+=1] = team1.division.name
        sheet1[pos,column+=1] = participant_registration.district.name
        sheet1[pos,column+=1] = participant_registration.district.region.name
        pos += 1
      end
      if !team2.nil?
        column = 0
        sheet1[pos,column] = participant_registration.full_name
        sheet1[pos,column+=1] = participant_registration.formatted_registration_type
        sheet1[pos,column+=1] = team2.name
        sheet1[pos,column+=1] = team2.division.name
        sheet1[pos,column+=1] = participant_registration.district.name
        sheet1[pos,column+=1] = participant_registration.district.region.name
        pos += 1
      end
      if !team3.nil?
        column = 0
        sheet1[pos,column] = participant_registration.full_name
        sheet1[pos,column+=1] = participant_registration.formatted_registration_type
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
    sheet1[0,column+=1] = 'Field'

    @ids = User.find(:all, :joins => [:team_registrations], :conditions => "event_id = #{params['event_id']}", :order => "first_name,last_name").map { |user| [user.id] }
    @ids.uniq!

    @group_leaders = User.find(@ids)
    @group_leaders = @group_leaders.uniq.sort_by { |user| user.fullname.downcase }

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

    sheet1.column(0).width = 20
    sheet1.column(1).width = 15
    sheet1.column(2).width = 30
    sheet1.column(3).width = 20
    sheet1.column(4).width = 20

    book.write "#{RAILS_ROOT}/public/download/group_leaders.xls"

    send_file "#{RAILS_ROOT}/public/download/group_leaders.xls", :filename => "group_leaders.xls"
  end

  # group leader summary report used for check in at the event
  # produces an excel document for download based upon the passed in group leader id
  def group_leader_summary
    book = Spreadsheet::Workbook.new
    active_event = !params['event_id'].nil? ? params['event_id'] : Event.active_event.id

    registration_options_meals = RegistrationOption.all(:conditions => 'category = "meal"', :order => 'sort')
    registration_options_other = RegistrationOption.all(:conditions => 'category = "other"', :order => 'sort')

    if (!params['group_leader'].blank?)
      sheet1 = book.create_worksheet

      if (params['group_leader'] == '-1')
        group_leader_name = 'Group Leader Not Listed'
        file_name = 'group_leader_not_listed'
        participants = ParticipantRegistration.by_event(active_event).by_group_leader(-1).ordered_by_last_name
      elsif (params['group_leader'] == '-2')
        group_leader_name = 'Group Leader Not Known'
        file_name = 'group_leader_not_known'
        participants = ParticipantRegistration.by_event(active_event).by_group_leader(-2).ordered_by_last_name
      elsif (params['group_leader'] == '-3')
        group_leader_name = 'No Group Leader'
        file_name = 'no_group_leader'
        participants = ParticipantRegistration.by_event(active_event).by_group_leader(-3).ordered_by_last_name
      elsif (params['group_leader'] == '-4')
        group_leader_name = 'Staff'
        file_name = 'staff'
        participants = ParticipantRegistration.by_event(active_event).by_group_leader(-4).ordered_by_last_name
      elsif (params['group_leader'] == '-5')
        group_leader_name = 'Official'
        file_name = 'official'
        participants = ParticipantRegistration.by_event(active_event).by_group_leader(-5).ordered_by_last_name
      elsif (params['group_leader'] == '-6')
        group_leader_name = 'Volunteer'
        file_name = 'volunteer'
        participants = ParticipantRegistration.by_event(active_event).by_group_leader(-6).ordered_by_last_name
      elsif (params['group_leader'] == '-7')
        group_leader_name = 'Representative'
        file_name = 'representative'
        participants = ParticipantRegistration.by_event(active_event).by_group_leader(-7).ordered_by_last_name
      else
        group_leader = User.find(params['group_leader'])
        group_leader_name = group_leader.fullname
        file_name = (group_leader.first_name + '_' + group_leader.last_name).downcase
        participants = group_leader.followers.by_event(active_event)
      end

      # filter to only active participants
      participants = participants.active

      # logic to remove registration options that noone has
      # this removes completely empty columns
      registration_options = Array.new
      complete_registration_options = registration_options_meals + registration_options_other
      complete_registration_options.each do |registration_option|
        used = false
        participants.each do |participant|
          if participant.registration_options.include?(registration_option)
            used = true
          end
        end
        used = false if registration_option.item == 'Off-Campus Housing Discount' # hide off campus discount
        registration_options.push(registration_option) if used == true
      end

      # formatting
      title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
      group_leader_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
      group_header_format = Spreadsheet::Format.new :weight => :bold, :align => :merge, :size => 9
      header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify, :size => 9
      data_format = Spreadsheet::Format.new :size => 9
      money_owed_format = Spreadsheet::Format.new :pattern_fg_color => :yellow, :pattern => 1, :size => 9

      # write out title
      column = 0
      sheet1[0,column] = 'Group Summary'
      sheet1[0,column+=1] = 'Group Leader: ' + group_leader_name
      sheet1.row(0).set_format(0,title_format)
      sheet1.row(0).set_format(1,group_leader_format)

      # write out group headers
      sheet1[1,4] = 'Teams'
      for i in 4..6
        sheet1.row(1).set_format(i,group_header_format)
      end
      sheet1[1,10] = 'Travel Information'
      for i in 10..11
        sheet1.row(1).set_format(i,group_header_format)
      end
      sheet1[1,12] = 'Registration Options' if registration_options.size > 0
      for i in 12..(12+registration_options.size-1)
        sheet1.row(1).set_format(i,group_header_format)
      end

      # write out headers
      column = 0
      sheet1[2,column] = 'Name'
      sheet1[2,column+=1] = 'Role'
      sheet1[2,column+=1] = 'Gender'
      sheet1[2,column+=1] = 'Shirt Size'
      sheet1[2,column+=1] = 'Team 1'
      sheet1[2,column+=1] = 'Team 2'
      sheet1[2,column+=1] = 'Team 3'
      sheet1[2,column+=1] = 'Housing'
      sheet1[2,column+=1] = 'Roommate Preference 1'
      sheet1[2,column+=1] = 'Roommate Preference 2'
      sheet1[2,column+=1] = 'Travel Type'
      sheet1[2,column+=1] = 'Travel Details'

      # registration options
      registration_options.each do |registration_option|
        sheet1[2,column+=1] = registration_option.item
      end

      sheet1.row(2).default_format = header_format

      # keep track of t-shirt numbers
      shirt_size_count = Hash.new
      shirt_size_count["undefined"] = 0
      
      pos = 3
      participants.each do |participant|
        column = 0
        sheet1[pos,column] = participant.full_name_reversed
        sheet1[pos,column+=1] = participant.formatted_registration_type
        sheet1[pos,column+=1] = participant.gender
        sheet1[pos,column+=1] = participant.shirt_size
        if participant.teams.size == 0
          sheet1[pos,column+=1] = ''
          sheet1[pos,column+=1] = ''
          sheet1[pos,column+=1] = ''
        elsif participant.teams.size == 1
          sheet1[pos,column+=1] = participant.teams[0].name_with_division
          sheet1[pos,column+=1] = ''
          sheet1[pos,column+=1] = ''
        elsif participant.teams.size == 2
          sheet1[pos,column+=1] = participant.teams[0].name_with_division
          sheet1[pos,column+=1] = participant.teams[1].name_with_division
          sheet1[pos,column+=1] = ''
        elsif participant.teams.size == 3
          sheet1[pos,column+=1] = participant.teams[0].name_with_division
          sheet1[pos,column+=1] = participant.teams[1].name_with_division
          sheet1[pos,column+=1] = participant.teams[2].name_with_division
        end

        # housing
        sheet1[pos,column+=1] = participant.housing
        sheet1[pos,column+=1] = participant.roommate_preference_1
        sheet1[pos,column+=1] = participant.roommate_preference_2
        
        # travel information
        sheet1[pos,column+=1] = participant.travel_type
        sheet1[pos,column+=1] = participant.travel_type_details

        # registration options
        registration_options.each do |registration_option|
          sheet1[pos,column+=1] = participant.registration_options.include?(registration_option) ? "YES" : ""
        end
          
        # set format
        for i in 1..column
          sheet1.row(pos).set_format(i,data_format)
        end

        # tabulate shirt size
        if participant.shirt_size.empty?
          shirt_size_count["undefined"] += 1
        else
          if shirt_size_count[participant.shirt_size].nil?
            shirt_size_count[participant.shirt_size] = 1
          else
            shirt_size_count[participant.shirt_size] += 1
          end
        end
      
        pos += 1
      end

      sheet1.column(0).width = 20
      sheet1.column(1).width = 12
      sheet1.column(2).width = 12
      sheet1.column(3).width = 12
      sheet1.column(4).width = 30
      sheet1.column(5).width = 30
      sheet1.column(6).width = 30
      sheet1.column(7).width = 20
      sheet1.column(8).width = 20
      sheet1.column(9).width = 20
      sheet1.column(10).width = 20
      sheet1.column(11).width = 30
      sheet1.column(12).width = 20

      for i in 12..(13+registration_options.size)
        sheet1.column(i).width = 20
      end

      # output shirt size counts
      pos += 2
      sheet1[pos,1] = "Shirt Sizes"
      sheet1.row(pos).set_format(1,group_header_format)
      sheet1.row(pos).set_format(2,group_header_format)
      pos += 1
      sheet1[pos,1] = "Small"
      sheet1[pos,2] = !shirt_size_count["Small"].nil? ? shirt_size_count["Small"] : 0
      pos += 1
      sheet1[pos,1] = "Medium"
      sheet1[pos,2] = !shirt_size_count["Medium"].nil? ? shirt_size_count["Medium"] : 0
      pos += 1
      sheet1[pos,1] = "Large"
      sheet1[pos,2] = !shirt_size_count["Large"].nil? ? shirt_size_count["Large"] : 0
      pos += 1
      sheet1[pos,1] = "X-Large"
      sheet1[pos,2] = !shirt_size_count["X-Large"].nil? ? shirt_size_count["X-Large"] : 0
      pos += 1
      sheet1[pos,1] = "2X-Large"
      sheet1[pos,2] = !shirt_size_count["2X-Large"].nil? ? shirt_size_count["2X-Large"] : 0
      pos += 1
      sheet1[pos,1] = "3X-Large"
      sheet1[pos,2] = !shirt_size_count["3X-Large"].nil? ? shirt_size_count["3X-Large"] : 0
      pos += 1
      sheet1[pos,1] = "4X-Large"
      sheet1[pos,2] = !shirt_size_count["4X-Large"].nil? ? shirt_size_count["4X-Large"] : 0
      pos += 1
      sheet1[pos,1] = "Undefined"
      sheet1[pos,2] = !shirt_size_count["undefined"].nil? ? shirt_size_count["undefined"] : 0

      book.write "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls", :filename => "group_leader_summary_#{file_name}.xls"
    else
      file_name = 'all'

      # save information about each sheet for later
      extra_information = Hash.new

      # loop through all group leaders
      group_leaders1 = User.find(:all, :joins => [:participant_registrations], :conditions => "num_novice_district_teams > 0 or num_experienced_district_teams > 0 or num_novice_local_teams > 0 or num_experienced_local_teams > 0", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
      group_leaders2 = User.find(:all, :joins => [:team_registrations], :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
      temp_group_leaders = group_leaders1 + group_leaders2
      temp_group_leaders = temp_group_leaders.uniq.sort_by { |user| user[0].downcase }
      group_leaders = temp_group_leaders.map { |user| user[1] }
      group_leaders.push(-1)
      group_leaders.push(-2)
      group_leaders.push(-3)
      group_leaders.push(-4)
      group_leaders.push(-5)
      group_leaders.push(-6)
      group_leaders.push(-7)

      group_leaders.each do |leader|

        if (leader == -1)
          group_leader_name = 'Group Leader Not Listed'
          participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-1)
        elsif (leader == -2)
          group_leader_name = 'Group Leader Not Known'
          participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-2)
        elsif (leader == -3)
          group_leader_name = 'No Group Leader'
          participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-3)
        elsif (leader == -4)
          group_leader_name = 'Staff'
          participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-4)
        elsif (leader == -5)
          group_leader_name = 'Official'
          participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-5)
        elsif (leader == -6)
          group_leader_name = 'Volunteer'
          participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-6)
        elsif (leader == -7)
          group_leader_name = 'Representative'
          participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-7)
        else
          user = User.find(leader)
          logger.debug(user)
          group_leader_name = user.fullname
          participants = user.followers.by_event(active_event)
        end

        # filter to only active participants
        participants = participants.active

        # skip if we don't have any participants
        if participants.size == 0
          next
        end

        # create our sheet
        tempbook = Spreadsheet::Workbook.new
        sheet1 = tempbook.create_worksheet

        # logic to remove registration options that noone has
        # this removes completely empty columns
        registration_options = Array.new
        complete_registration_options = registration_options_meals + registration_options_other
        complete_registration_options.each do |registration_option|
          used = false
          participants.each do |participant|
            if participant.registration_options.include?(registration_option)
              used = true
            end
          end
          used = false if registration_option.item == 'Off-Campus Housing Discount' # hide off campus discount
          registration_options.push(registration_option) if used == true
        end

        # formatting
        title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
        group_leader_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
        group_header_format = Spreadsheet::Format.new :weight => :bold, :align => :merge, :size => 9
        header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify, :size => 9
        data_format = Spreadsheet::Format.new :size => 9
        money_owed_format = Spreadsheet::Format.new :pattern_fg_color => :yellow, :pattern => 1, :size => 9

        # write out title
        column = 0
        sheet1[0,column] = 'Group Summary'
        sheet1[0,column+=1] = 'Group Leader: ' + group_leader_name
  
        # write out group headers
        sheet1[1,4] = 'Teams'
        sheet1[1,10] = 'Travel Information'
        sheet1[1,12] = 'Registration Options' if registration_options.size > 0
  
        # write out headers
        column = 0
        sheet1[2,column] = 'Name'
        sheet1[2,column+=1] = 'Role'
        sheet1[2,column+=1] = 'Gender'
        sheet1[2,column+=1] = 'Shirt Size'
        sheet1[2,column+=1] = 'Team 1'
        sheet1[2,column+=1] = 'Team 2'
        sheet1[2,column+=1] = 'Team 3'
        sheet1[2,column+=1] = 'Housing'
        sheet1[2,column+=1] = 'Roommate Preference 1'
        sheet1[2,column+=1] = 'Roommate Preference 2'
        sheet1[2,column+=1] = 'Travel Type'
        sheet1[2,column+=1] = 'Travel Details'

        # registration options
        registration_options.each do |registration_option|
          sheet1[2,column+=1] = registration_option.item
        end

        # keep track of t-shirt numbers
        shirt_size_count = Hash.new
        shirt_size_count["undefined"] = 0
      
        pos = 3
        participants.each do |participant|
          column = 0
          sheet1[pos,column] = participant.full_name_reversed
          sheet1[pos,column+=1] = participant.formatted_registration_type
          sheet1[pos,column+=1] = participant.gender
          sheet1[pos,column+=1] = participant.shirt_size
          if participant.teams.size == 0
            sheet1[pos,column+=1] = ''
            sheet1[pos,column+=1] = ''
            sheet1[pos,column+=1] = ''
          elsif participant.teams.size == 1
            sheet1[pos,column+=1] = participant.teams[0].name_with_division
            sheet1[pos,column+=1] = ''
            sheet1[pos,column+=1] = ''
          elsif participant.teams.size == 2
            sheet1[pos,column+=1] = participant.teams[0].name_with_division
            sheet1[pos,column+=1] = participant.teams[1].name_with_division
            sheet1[pos,column+=1] = ''
          elsif participant.teams.size == 3
            sheet1[pos,column+=1] = participant.teams[0].name_with_division
            sheet1[pos,column+=1] = participant.teams[1].name_with_division
            sheet1[pos,column+=1] = participant.teams[2].name_with_division
          end
  
          # housing
          sheet1[pos,column+=1] = participant.housing
          sheet1[pos,column+=1] = participant.roommate_preference_1
          sheet1[pos,column+=1] = participant.roommate_preference_2
          
          # travel information
          sheet1[pos,column+=1] = participant.travel_type
          sheet1[pos,column+=1] = participant.travel_type_details
          
          # registration options
          registration_options.each do |registration_option|
            sheet1[pos,column+=1] = participant.registration_options.include?(registration_option) ? "YES" : ""
          end
          
          # set format
          for i in 1..column
            sheet1.row(pos).set_format(i,data_format)
          end

          # tabulate shirt size
          if participant.shirt_size.empty?
            shirt_size_count["undefined"] += 1
          else
            if shirt_size_count[participant.shirt_size].nil?
              shirt_size_count[participant.shirt_size] = 1
            else
              shirt_size_count[participant.shirt_size] += 1
            end
          end
          
          pos += 1
        end
  
        sheet1.column(0).width = 25
        sheet1.column(1).width = 12
        sheet1.column(2).width = 12
        sheet1.column(3).width = 12
        sheet1.column(4).width = 30
        sheet1.column(5).width = 30
        sheet1.column(6).width = 30
        sheet1.column(7).width = 20
        sheet1.column(8).width = 20
        sheet1.column(9).width = 20
        sheet1.column(10).width = 20
        sheet1.column(11).width = 30
        sheet1.column(12).width = 20

        for i in 12..(13+registration_options.size)
          sheet1.column(i).width = 20
        end

        # output shirt size counts
        pos += 2
        sheet1[pos,1] = "Shirt Sizes"
        sheet1.row(pos).set_format(1,group_header_format)
        sheet1.row(pos).set_format(2,group_header_format)
        pos += 1
        sheet1[pos,1] = "Small"
        sheet1[pos,2] = !shirt_size_count["Small"].nil? ? shirt_size_count["Small"] : 0
        pos += 1
        sheet1[pos,1] = "Medium"
        sheet1[pos,2] = !shirt_size_count["Medium"].nil? ? shirt_size_count["Medium"] : 0
        pos += 1
        sheet1[pos,1] = "Large"
        sheet1[pos,2] = !shirt_size_count["Large"].nil? ? shirt_size_count["Large"] : 0
        pos += 1
        sheet1[pos,1] = "XLarge"
        sheet1[pos,2] = !shirt_size_count["XLarge"].nil? ? shirt_size_count["XLarge"] : 0
        pos += 1
        sheet1[pos,1] = "2XLarge"
        sheet1[pos,2] = !shirt_size_count["2XLarge"].nil? ? shirt_size_count["2XLarge"] : 0
        pos += 1
        sheet1[pos,1] = "3XLarge"
        sheet1[pos,2] = !shirt_size_count["3XLarge"].nil? ? shirt_size_count["3XLarge"] : 0
        pos += 1
        sheet1[pos,1] = "4XLarge"
        sheet1[pos,2] = !shirt_size_count["4XLarge"].nil? ? shirt_size_count["4XLarge"] : 0
        pos += 1
        sheet1[pos,1] = "Undefined"
        sheet1[pos,2] = !shirt_size_count["undefined"].nil? ? shirt_size_count["undefined"] : 0
        
        sheet1.name = group_leader_name
        extra_information[group_leader_name] = {'registration_options_size' => registration_options.size, 'num_participants' => participants.size}

        book.add_worksheet(sheet1)
      end

      # loop through and do all the formatting
      # this has to be outside the loop because it doesn't work for some sheets (odd behavior)
      book.worksheets.each do |sheet|
        extra = extra_information[sheet.name]
        logger.info("SHEET NAME: " + sheet.name)
        logger.info("EXTRA: " + extra.inspect)
        sheet.row(0).set_format(0,title_format)
        sheet.row(0).set_format(1,group_leader_format)

        for i in 4..6
          sheet.row(1).set_format(i,group_header_format)
        end
        for i in 10..11
          sheet.row(1).set_format(i,group_header_format)
        end
        for i in 12..(12+extra['registration_options_size'])
          sheet.row(1).set_format(i,group_header_format)
        end
        sheet.row(0).set_format(0,title_format)
        sheet.row(0).set_format(1,group_leader_format)

        sheet.row(2).default_format = header_format

        # shirt sizes title
        sheet.row(5+extra['num_participants']).set_format(1,group_header_format)
        sheet.row(5+extra['num_participants']).set_format(2,group_header_format)
      end

      book.write "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/group_leader_summary_#{file_name}.xls", :filename => "group_leader_summary_#{file_name}.xls"
    end
  end

  # report used for check in at the event
  def event_checkin
    book = Spreadsheet::Workbook.new
    active_event = !params['event_id'].nil? ? params['event_id'] : Event.active_event.id

    # formatting
    title_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
    group_leader_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 16
    group_header_format = Spreadsheet::Format.new :weight => :bold, :align => :merge, :size => 9
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify, :size => 9
    data_format = Spreadsheet::Format.new :size => 9
    money_owed_format = Spreadsheet::Format.new :pattern_fg_color => :yellow, :pattern => 1, :size => 9

    registration_options_meals = RegistrationOption.all(:conditions => 'category = "meal"', :order => 'sort')
    registration_options_other = RegistrationOption.all(:conditions => 'category = "other"', :order => 'sort')

    # save information about each sheet for later
    extra_information = Hash.new

    # loop through all group leaders
    group_leaders1 = User.find(:all, :joins => [:participant_registrations], :conditions => "num_novice_district_teams > 0 or num_experienced_district_teams > 0 or num_novice_local_teams > 0 or num_experienced_local_teams > 0", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    group_leaders2 = User.find(:all, :joins => [:team_registrations], :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
    temp_group_leaders = group_leaders1 + group_leaders2
    temp_group_leaders = temp_group_leaders.uniq.sort_by { |user| user[0].downcase }
    group_leaders = temp_group_leaders.map { |user| user[1] }
    group_leaders.push(-1)
    group_leaders.push(-2)
    group_leaders.push(-3)
    group_leaders.push(-4)
    group_leaders.push(-5)
    group_leaders.push(-6)
    group_leaders.push(-7)

    group_leaders.each do |leader|

      if (leader == -1)
        group_leader_name = 'Group Leader Not Listed'
        participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-1)
      elsif (leader == -2)
        group_leader_name = 'Group Leader Not Known'
        participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-2)
      elsif (leader == -3)
        group_leader_name = 'No Group Leader'
        participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-3)
      elsif (leader == -4)
        group_leader_name = 'Staff'
        participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-4)
      elsif (leader == -5)
        group_leader_name = 'Official'
        participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-5)
      elsif (leader == -6)
        group_leader_name = 'Volunteer'
        participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-6)
      elsif (leader == -7)
        group_leader_name = 'Representative'
        participants = ParticipantRegistration.by_event(active_event).ordered_by_last_name.by_group_leader(-7)
      else
        user = User.find(leader)
        logger.debug(user)
        group_leader_name = user.fullname
        participants = user.followers.by_event(active_event)
      end

      # filter to only active participants
      participants = participants.active

      # skip if we don't have any participants
      if participants.size == 0
        next
      end

      # create our sheet
      tempbook = Spreadsheet::Workbook.new
      sheet1 = tempbook.create_worksheet

      # logic to remove registration options that no one has
      # this removes completely empty columns
      registration_options = Array.new
      complete_registration_options = registration_options_meals + registration_options_other
      complete_registration_options.each do |registration_option|
        used = false
        participants.each do |participant|
          if participant.registration_options.include?(registration_option)
            used = true
          end
        end
        used = false if registration_option.item == 'Off-Campus Housing Discount' # hide off campus discount
        registration_options.push(registration_option) if used == true
      end

      # logic to remove teams if no one has a second and third team
      # this removes completely empty columns
      num_teams = 0
      participants.each do |participant|
        if participant.teams.size > num_teams
          num_teams = participant.teams.size
        end
      end

      # write out title
      column = 0
      sheet1[0,column] = 'Group Summary'
      sheet1[0,column+=1] = 'Group Leader: ' + group_leader_name

      # write out group headers
      if num_teams > 0
        sheet1[1,4] = 'Teams'
      end
      sheet1[1,5+num_teams] = 'Registration Options'

      # write out headers
      column = 0
      sheet1[2,column] = 'Name'
      sheet1[2,column+=1] = 'Role'
      sheet1[2,column+=1] = 'Gender'
      sheet1[2,column+=1] = 'Shirt Size'
      num_teams.times do |i|
        sheet1[2,column+=1] = "Team #{i+1}"
      end
      sheet1[2,column+=1] = 'Housing'

      # registration options
      registration_options.each do |registration_option|
        sheet1[2,column+=1] = registration_option.item
      end

      sheet1[2,column+=1] = 'Medical Liability Received'

      # keep track of t-shirt numbers
      shirt_size_count = Hash.new
      shirt_size_count["undefined"] = 0
    
      pos = 3
      participants.each do |participant|
        column = 0
        sheet1[pos,column] = participant.full_name_reversed
        sheet1[pos,column+=1] = participant.formatted_registration_type
        sheet1[pos,column+=1] = participant.gender
        sheet1[pos,column+=1] = participant.shirt_size
        num_teams.times do |i|
          if !participant.teams[i].nil?
            sheet1[pos,column+=1] = participant.teams[i].name_with_division
          else
            sheet1[pos,column+=1] = ''
          end
        end

        # housing
        sheet1[pos,column+=1] = participant.housing
        
        # registration options
        registration_options.each do |registration_option|
          sheet1[pos,column+=1] = participant.registration_options.include?(registration_option) ? "YES" : ""
        end

        # other stuff
        sheet1[pos,column+=1] = participant.medical_liability? ? 'YES' : ''
        
        # set format
        for i in 1..column
          sheet1.row(pos).set_format(i,data_format)
        end

        # tabulate shirt size
        if participant.shirt_size.empty?
          shirt_size_count["undefined"] += 1
        else
          if shirt_size_count[participant.shirt_size].nil?
            shirt_size_count[participant.shirt_size] = 1
          else
            shirt_size_count[participant.shirt_size] += 1
          end
        end
        
        pos += 1
      end

      sheet1.column(0).width = 25
      sheet1.column(1).width = 12
      sheet1.column(2).width = 12
      sheet1.column(3).width = 12
      num_teams.times do |i|
        sheet1.column(4+i).width = 30
      end
      sheet1.column(4+num_teams).width = 30

      # output shirt size counts
      pos += 2
      sheet1[pos,1] = "Shirt Sizes"
      sheet1.row(pos).set_format(1,group_header_format)
      sheet1.row(pos).set_format(2,group_header_format)
      pos += 1
      sheet1[pos,1] = "Small"
      sheet1[pos,2] = !shirt_size_count["Small"].nil? ? shirt_size_count["Small"] : 0
      pos += 1
      sheet1[pos,1] = "Medium"
      sheet1[pos,2] = !shirt_size_count["Medium"].nil? ? shirt_size_count["Medium"] : 0
      pos += 1
      sheet1[pos,1] = "Large"
      sheet1[pos,2] = !shirt_size_count["Large"].nil? ? shirt_size_count["Large"] : 0
      pos += 1
      sheet1[pos,1] = "XLarge"
      sheet1[pos,2] = !shirt_size_count["XLarge"].nil? ? shirt_size_count["XLarge"] : 0
      pos += 1
      sheet1[pos,1] = "2XLarge"
      sheet1[pos,2] = !shirt_size_count["2XLarge"].nil? ? shirt_size_count["2XLarge"] : 0
      pos += 1
      sheet1[pos,1] = "3XLarge"
      sheet1[pos,2] = !shirt_size_count["3XLarge"].nil? ? shirt_size_count["3XLarge"] : 0
      pos += 1
      sheet1[pos,1] = "4XLarge"
      sheet1[pos,2] = !shirt_size_count["4XLarge"].nil? ? shirt_size_count["4XLarge"] : 0
      pos += 1
      sheet1[pos,1] = "Undefined"
      sheet1[pos,2] = !shirt_size_count["undefined"].nil? ? shirt_size_count["undefined"] : 0
      
      sheet1.name = group_leader_name
      extra_information[group_leader_name] = {'registration_options_size' => registration_options.size, 'num_participants' => participants.size, 'num_teams' => num_teams}

      book.add_worksheet(sheet1)
    end

    # loop through and do all the formatting
    # this has to be outside the loop because it doesn't work for some sheets (odd behavior)
    book.worksheets.each do |sheet|
      extra = extra_information[sheet.name]
      sheet.row(0).set_format(0,title_format)
      sheet.row(0).set_format(1,group_leader_format)

    ending_column = 3+extra['num_teams']
      if extra['num_teams'] > 0
        for i in 4..ending_column
          sheet.row(1).set_format(i,group_header_format)
        end
      end
      for i in 10..11
        sheet.row(1).set_format(i,group_header_format)
      end
      for i in 5+extra['num_teams']..(5+extra['num_teams']+extra['registration_options_size'])
        sheet.row(1).set_format(i,group_header_format)
      end
      sheet.row(0).set_format(0,title_format)
      sheet.row(0).set_format(1,group_leader_format)

      sheet.row(2).default_format = header_format

      # shirt sizes title
      sheet.row(5+extra['num_participants']).set_format(1,group_header_format)
      sheet.row(5+extra['num_participants']).set_format(2,group_header_format)
    end

    book.write "#{RAILS_ROOT}/public/download/event_checkin.xls"

    send_file "#{RAILS_ROOT}/public/download/event_checkin.xls", :filename => "event_checkin.xls"
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

    @equipment_registrations = EquipmentRegistration.all(:conditions => "event_id = #{params['event_id']}", :order => 'last_name asc')

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

  # housing report by building
  # produces an excel document for download based upon the passed in building_id
  # if no building id is passed in then we produce an excel document with all
  # buildings with one building per tab.
  def housing_by_building
    book = Spreadsheet::Workbook.new

    if (!params['building_id'].blank?)
      sheet1 = book.create_worksheet

      building = Building.find(params[:building_id])
      participants = ParticipantRegistration.by_building(params[:building_id]).by_event(params['event_id']).ordered_by_room

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
      sheet1[1,column+=1] = 'Field'
      sheet1[1,column+=1] = 'Group Leader'
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
        sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
        sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

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
        elsif (participant.group_leader == '-7')
          group_leader_name = 'Representative'
        else
          if !participant.group_leader.nil? and !participant.group_leader.empty?
            user = User.find(participant.group_leader)
            group_leader_name = user.fullname
          end
        end
        sheet1[pos,column+=1] = group_leader_name

        pos += 1
      end

      sheet1.column(2).width = 25
      sheet1.column(5).width = 25
      sheet1.column(6).width = 25

      file_name = building.name.downcase

      book.write "#{RAILS_ROOT}/public/download/housing_by_building_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/housing_by_building_#{file_name}.xls", :filename => "housing_by_building_#{file_name}.xls"
    else
      file_name = 'all'
      buildings = Building.all(:order => 'name asc', :conditions => "event_id = #{params['event_id']}")

      buildings.each do |building|
        sheet1 = book.create_worksheet
        participants = ParticipantRegistration.by_building(building.id).by_event(params['event_id']).ordered_by_room

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
        sheet1[1,column+=1] = 'Field'
        sheet1[1,column+=1] = 'Group Leader'
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
          sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
          sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

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
          elsif (participant.group_leader == '-7')
            group_leader_name = 'Representative'
          else
            if !participant.group_leader.nil? and !participant.group_leader.empty?
              user = User.find(participant.group_leader)
              group_leader_name = user.fullname
            end
          end
          sheet1[pos,column+=1] = group_leader_name

          pos += 1
        end

        sheet1.column(2).width = 25
        sheet1.column(5).width = 25
        sheet1.column(6).width = 25

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
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-1).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-2')
        group_leader_name = 'Group Leader Not Known'
        file_name = 'group_leader_not_known'
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-2).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-3')
        group_leader_name = 'No Group Leader'
        file_name = 'no_group_leader'
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-3).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-4')
        group_leader_name = 'Staff'
        file_name = 'staff'
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-4).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-5')
        group_leader_name = 'Official'
        file_name = 'official'
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-5).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-6')
        group_leader_name = 'Volunteer'
        file_name = 'volunteer'
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-6).ordered_by_building_room_last_name
      elsif (params['group_leader'] == '-7')
        group_leader_name = 'Representative'
        file_name = 'representative'
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-7).ordered_by_building_room_last_name
      else
        group_leader = User.find(params['group_leader'])
        group_leader_name = group_leader.fullname
        file_name = (group_leader.first_name + '_' + group_leader.last_name).downcase
        participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(params['group_leader']).ordered_by_building_room_last_name
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
      sheet1[1,column+=1] = 'Field'
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
        sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
        sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

        pos += 1
      end

      sheet1.column(0).width = 20
      sheet1.column(3).width = 25
      sheet1.column(6).width = 20

      book.write "#{RAILS_ROOT}/public/download/housing_by_group_leader_#{file_name}.xls"

      send_file "#{RAILS_ROOT}/public/download/housing_by_group_leader_#{file_name}.xls", :filename => "housing_by_building_#{file_name}.xls"
    else
      file_name = 'all'

      # loop through all group leaders
      group_leaders1 = User.find(:all, :joins => [:participant_registrations], :conditions => "event_id = #{params['event_id']} and (num_novice_district_teams > 0 or num_experienced_district_teams > 0 or num_novice_local_teams > 0 or num_experienced_local_teams > 0)", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
      group_leaders2 = User.find(:all, :joins => [:team_registrations], :conditions => "event_id = #{params['event_id']}", :order => "first_name,last_name").map { |user| [user.fullname, user.id] }
      temp_group_leaders = group_leaders1 + group_leaders2
      temp_group_leaders = temp_group_leaders.uniq.sort_by { |user| user[0].downcase }
      group_leaders = temp_group_leaders.map { |user| user[1] }
      group_leaders.push(-1)
      group_leaders.push(-2)
      group_leaders.push(-3)
      group_leaders.push(-4)
      group_leaders.push(-5)
      group_leaders.push(-6)
      group_leaders.push(-7)

      group_leaders.each do |leader|

        if (leader == -1)
          group_leader_name = 'Group Leader Not Listed'
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-1).ordered_by_building_room_last_name
        elsif (leader == -2)
          group_leader_name = 'Group Leader Not Known'
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-2).ordered_by_building_room_last_name
        elsif (leader == -3)
          group_leader_name = 'No Group Leader'
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-3).ordered_by_building_room_last_name
        elsif (leader == -4)
          group_leader_name = 'Staff'
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-4).ordered_by_building_room_last_name
        elsif (leader == -5)
          group_leader_name = 'Official'
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-5).ordered_by_building_room_last_name
        elsif (leader == -6)
          group_leader_name = 'Volunteer'
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-6).ordered_by_building_room_last_name
        elsif (leader == -7)
          group_leader_name = 'Representative'
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(-7).ordered_by_building_room_last_name
        else
          user = User.find(leader)
          group_leader_name = user.fullname
          participants = ParticipantRegistration.by_event(params['event_id']).by_group_leader(leader).ordered_by_building_room_last_name
        end

        # skip if we don't have any participants
        if participants.size == 0
          next
        end

        # create our sheet
        sheet1 = book.create_worksheet

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
        sheet1[1,column+=1] = 'Field'
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
          sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
          sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

          pos += 1
        end

        sheet1.column(0).width = 20
        sheet1.column(3).width = 25
        sheet1.column(6).width = 20

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
      participants = ParticipantRegistration.by_event(params['event_id']).by_ministry_project(params[:ministry_project_id]).ordered_by_last_name

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
      sheet1[1,column+=1] = 'Field'
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
        sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
        sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

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
        elsif (participant.group_leader == '-7')
          group_leader_name = 'Representative'
        else
          if !participant.group_leader.nil? and !participant.group_leader.empty?
            user = User.find(participant.group_leader)
            group_leader_name = user.fullname
          end
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
        participants = ParticipantRegistration.by_event(params['event_id']).by_ministry_project(ministry_project.id).ordered_by_last_name

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
        sheet1[1,column+=1] = 'Field'
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
          sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
          sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

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
          elsif (participant.group_leader == '-7')
            group_leader_name = 'Representative'
          else
            if !participant.group_leader.nil? and !participant.group_leader.empty?
              user = User.find(participant.group_leader)
              group_leader_name = user.fullname
            end
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
    sheet1[0,column+=1] = 'Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Field'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'Group Leader Email'
    sheet1[0,column+=1] = 'Liability Form'
    sheet1.row(0).default_format = header_format

    if params[:received]
      @participants = ParticipantRegistration.medical_liability_complete.by_event(params['event_id']).ordered_by_last_name
      file_name = 'received'
    elsif params[:not_received]
      @participants = ParticipantRegistration.medical_liability_incomplete.by_event(params['event_id']).ordered_by_last_name
      file_name = 'not_received'
    else
      @participants = ParticipantRegistration.by_event(params['event_id']).ordered_by_last_name
      file_name = 'all'
    end

    pos = 1
    @participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

      # group leader
      group_leader_email = ''
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
      elsif (participant.group_leader == '-7')
        group_leader_name = 'Representative'
      else
        if !participant.group_leader.nil? and !participant.group_leader.empty?
          user = User.find(participant.group_leader)
          group_leader_name = user.fullname
          group_leader_email = user.email
        end
      end
      sheet1[pos,column+=1] = group_leader_name
      sheet1[pos,column+=1] = group_leader_email

      sheet1[pos,column+=1] = participant.medical_liability? ? 'Recieved' : 'Not Received'

      pos += 1
    end

    for i in 0..7
      sheet1.column(i).width = 20
    end
    sheet1.column(2).width = 30
    sheet1.column(6).width = 30

    book.write "#{RAILS_ROOT}/public/download/participants_liability_#{file_name}.xls"

    send_file "#{RAILS_ROOT}/public/download/participants_liability_#{file_name}.xls", :filename => "participants_liability_#{file_name}.xls"
  end

  # generate a report of participants that requested a shuttle
  def participants_shuttle
    @participants = ParticipantRegistration.bought_shuttle.complete.by_event(params['event_id']).ordered_by_last_name
    @report_type = 'shuttle'
    participants_travel_details
  end

  # generate a report of participants that are flying to the event
  def participants_flying
    @participants = ParticipantRegistration.is_flying.complete.by_event(params['event_id']).ordered_by_last_name
    @report_type = 'flying'
    participants_travel_details
  end

  # create a downloadable excel of participants and their flight details
  def participants_travel_details
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Name'
    sheet1[0,column+=1] = 'Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Field'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'Travel Type'
    sheet1[0,column+=1] = 'Shuttle Service?'
    sheet1[0,column+=1] = 'Flight Details'
    sheet1.row(0).default_format = header_format

    pos = 1
    @participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

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
      elsif (participant.group_leader == '-7')
        group_leader_name = 'Representative'
      else
        if !participant.group_leader.nil? and !participant.group_leader.empty?
          user = User.find(participant.group_leader)
          group_leader_name = user.fullname
        end
      end
      sheet1[pos,column+=1] = group_leader_name

      sheet1[pos,column+=1] = participant.travel_type

      shuttle = RegistrationOption.find_by_item('Shuttle')
      sheet1[pos,column+=1] = participant.registration_options.include?(shuttle) ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant.travel_type_details

      pos += 1
    end

    for i in 0..7
      sheet1.column(i).width = 20
    end
    sheet1.column(8).width = 50

    book.write "#{RAILS_ROOT}/public/download/participants_#{@report_type}.xls"

    send_file "#{RAILS_ROOT}/public/download/participants_#{@report_type}.xls", :filename => "participants_#{@report_type}.xls"
  end

  # create a downloadable excel of participants who are officials
  def officials
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    # find only officials
    @participants = ParticipantRegistration.find(:all, :conditions => "registration_type = 'official' and event_id = #{params['event_id']}")

    # formatting
    header_format = Spreadsheet::Format.new :weight => :bold, :align => :justify

    # write out headers
    column = 0
    sheet1[0,column] = 'Name'
    sheet1[0,column+=1] = 'Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Field'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'Planning on Coaching'
    sheet1.row(0).default_format = header_format

    pos = 1
    @participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''

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
      elsif (participant.group_leader == '-7')
        group_leader_name = 'Representative'
      else
        if !participant.group_leader.nil? and !participant.group_leader.empty?
          user = User.find(participant.group_leader)
          group_leader_name = user.fullname
        end
      end
      sheet1[pos,column+=1] = group_leader_name

      sheet1[pos,column+=1] = participant.planning_on_coaching ? "YES" : "NO"

      pos += 1
    end

    for i in 0..7
      sheet1.column(i).width = 20
    end
    sheet1.column(3).width = 30

    book.write "#{RAILS_ROOT}/public/download/officials.xls"

    send_file "#{RAILS_ROOT}/public/download/officials.xls", :filename => "officials.xls"
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
    sheet1[0,column+=1] = 'Phone'
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Field'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1.row(0).default_format = header_format
       
    @participants = ParticipantRegistration.no_team.by_event(params['event_id'])
                         
    pos = 1
    @participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.formatted_registration_type
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''
      
      # group leader
      group_leader_name = ''
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
      elsif (participant.group_leader == '-7')
        group_leader_name = 'Representative'
      else
        if !participant.group_leader.nil? and !participant.group_leader.empty?
          user = User.find(participant.group_leader)
          group_leader_name = user.fullname
        end
      end
      sheet1[pos,column+=1] = group_leader_name

      pos += 1
    end

    for i in 0..6
      sheet1.column(i).width = 20
    end
    sheet1.column(3).width = 30

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
    sheet1[0,column+=1] = 'Field'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.by_event(params['event_id']).ordered_by_last_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = !participant.ministry_project.blank? ? participant.ministry_project.name : ''
      sheet1[pos,column+=1] = !participant.ministry_project_group.blank? ? participant.ministry_project_group : ''
      sheet1[pos,column+=1] = participant.gender
      sheet1[pos,column+=1] = participant.formatted_registration_type
      sheet1[pos,column+=1] = participant.most_recent_grade
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''
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

  # create a downloadable excel file of pre housing on one sheet
  def housing_pre
    @only_pre = true
    @filename = 'pre'
    housing
  end
  
  # create a downloadable excel file of off campus guests on one sheet
  def housing_offcampus
    @only_offcampus = true
    @filename = 'offcampus'
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

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.by_event(params['event_id']).ordered_by_last_name

    pos = 1
    participants.each do |participant|
      if @only_pre && !participant.housing_saturday? && !participant.housing_sunday?
        next
      end
      
      if @only_offcampus && participant.registration_type != "Guest (Lodging off-campus)"
        next
      end

      column = 0
      sheet1[pos,column] = !participant.building.blank? ? participant.building.name : ''
      sheet1[pos,column+=1] = !participant.room.blank? ? participant.room : ''
      sheet1[pos,column+=1] = participant.keycode
      sheet1[pos,column+=1] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.group_leader_name
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 20
    sheet1.column(1).width = 10
    sheet1.column(2).width = 10
    sheet1.column(3).width = 25
    sheet1.column(4).width = 25
    sheet1.column(5).width = 25

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
    sheet1[0,column+=1] = 'Email'
    sheet1[0,column+=1] = 'Gender'
    sheet1[0,column+=1] = 'Group Leader'
    sheet1[0,column+=1] = 'District'
    sheet1[0,column+=1] = 'Food Allergies'
    sheet1[0,column+=1] = 'Handicap Accessible'
    sheet1[0,column+=1] = 'Hearing Impaired'
    sheet1[0,column+=1] = 'Vision Impaired'
    sheet1[0,column+=1] = 'Other'
    sheet1[0,column+=1] = 'Special Need Details'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.has_special_needs.by_event(params['event_id']).ordered_by_last_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = participant.gender
      sheet1[pos,column+=1] = participant.group_leader_name
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = participant.special_needs_food_allergies ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant.special_needs_handicap_accessible ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant.special_needs_hearing_impaired ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant.special_needs_vision_impaired ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant.special_needs_other ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant.special_needs_details
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 25
    sheet1.column(1).width = 25
    sheet1.column(2).width = 10
    sheet1.column(3).width = 25
    sheet1.column(4).width = 25
    sheet1.column(5).width = 10
    sheet1.column(6).width = 10
    sheet1.column(7).width = 10
    sheet1.column(8).width = 10
    sheet1.column(9).width = 10
    sheet1.column(10).width = 100

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
    sheet1[0,column+=1] = 'Field'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.by_registration_type('staff').by_event(params['event_id']).ordered_by_first_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.region.name : ''
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 25
    sheet1.column(1).width = 15
    sheet1.column(2).width = 30
    sheet1.column(3).width = 25
    sheet1.column(4).width = 25

    book.write "#{RAILS_ROOT}/public/download/event_staff.xls"

    send_file "#{RAILS_ROOT}/public/download/event_staff.xls", :filename => "event_staff.xls"
  end
  
  # create a downloadable excel of participants who requested a shuttle, but don't have flight info
  def shuttle_no_flight_info
    self.shuttle ParticipantRegistration.needs_shuttle.no_flight_info.by_event(params['event_id']), 'no_flight'
  end
  
  # create a downloadable excel of participants who requested a shuttle
  def shuttle_all
    self.shuttle ParticipantRegistration.needs_shuttle.by_event(params['event_id'])
  end
end
