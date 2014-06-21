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
    @group_leaders.push(['Representative', -7])
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
    sheet1[0,8] = 'Registration Time'

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
        sheet1[pos,8] = team_registration.created_at.strftime("%m/%d/%Y %H:%M:%S")
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
    sheet1[0,column+=1] = 'Special Needs?'
    sheet1[0,column+=1] = 'Special Needs Details'
    sheet1[0,column+=1] = 'Travel Type'
    sheet1[0,column+=1] = 'Arrival Date'
    sheet1[0,column+=1] = 'Arrival Airline'
    sheet1[0,column+=1] = 'Arrival Airline Flight Number'
    sheet1[0,column+=1] = 'Departure Date'
    sheet1[0,column+=1] = 'Departure Airline'
    sheet1[0,column+=1] = 'Departure Airline Flight Number'
    sheet1[0,column+=1] = 'Airport Shuttle'
    sheet1[0,column+=1] = 'Housing June 28th'
    sheet1[0,column+=1] = 'Housing June29th'
    sheet1[0,column+=1] = 'Medical / Liability?'
    sheet1[0,column+=1] = 'Amount Ordered'
    sheet1[0,column+=1] = 'Amount Paid'
    sheet1[0,column+=1] = 'Amount Due'
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
      sheet1[pos,column+=1] = participant_registration.mobile_phone
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

      # ministry project
      if !participant_registration.ministry_project.nil? or !participant_registration.ministry_project_group.blank?
        assignment = ''
        assignment += participant_registration.ministry_project ? participant_registration.ministry_project.name : ''
        assignment += !participant_registration.ministry_project_group.blank? ? ' - ' + participant_registration.ministry_project_group : ''
        sheet1[pos,column+=1] = assignment
      else
        sheet1[pos,column+=1] = ''
      end

      sheet1[pos,column+=1] = !participant_registration.special_needs.nil? ? participant_registration.special_needs.upcase : '' 
      sheet1[pos,column+=1] = participant_registration.special_needs_details

      sheet1[pos,column+=1] = participant_registration.travel_type

      # arrival date
      if participant_registration.travel_type == 'I am driving to the event.'
        sheet1[pos,column+=1] = participant_registration.driving_arrival_date
      elsif participant_registration.travel_type == 'I am flying to the event.'
        sheet1[pos,column+=1] = participant_registration.airline_arrival_date
      else
        sheet1[pos,column+=1] = ''
        sheet1[pos,column+=1] = ''
      end

      sheet1[pos,column+=1] = participant_registration.arrival_airline
      sheet1[pos,column+=1] = participant_registration.arrival_flight_number
      sheet1[pos,column+=1] = participant_registration.airline_departure_date
      sheet1[pos,column+=1] = participant_registration.departure_airline
      sheet1[pos,column+=1] = participant_registration.departure_flight_number
      sheet1[pos,column+=1] = participant_registration.airport_transportation? ? 'YES' : ''
      sheet1[pos,column+=1] = participant_registration.housing_saturday? ? 'YES' : ''
      sheet1[pos,column+=1] = participant_registration.housing_sunday? ? 'YES' : ''
      sheet1[pos,column+=1] = participant_registration.medical_liability? ? 'YES' : 'NO'
      sheet1[pos,column+=1] = participant_registration.amount_ordered
      sheet1[pos,column+=1] = participant_registration.amount_paid
      sheet1[pos,column+=1] = participant_registration.amount_due
      sheet1[pos,column+=1] = participant_registration.created_at.strftime("%m/%d/%Y %H:%M:%S")
      sheet1[pos,column+=1] = participant_registration.updated_at.strftime("%m/%d/%Y %H:%M:%S")
      pos += 1
    end
    book.write "#{RAILS_ROOT}/public/download/participant_registrations_#{@report_type}.xls"

    send_file "#{RAILS_ROOT}/public/download/participant_registrations_#{@report_type}.xls", :filename => "participant_registrations_#{@report_type}.xls"
  end

  # generate a report of coaches and teams (this only grabs coaches with a complete registration)
  def coaches_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => 'registration_type = "Coach"', :order => 'last_name asc, first_name asc')
    @report_type = 'coaches'
    participants_teams
  end

  # generate a report of quizzers and teams (this only grabs quizzers with a complete registration)
  def quizzers_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => 'registration_type = "Quizzer"', :order => 'last_name asc, first_name asc')
    @report_type = 'quizzers'
    participants_teams
  end

  # generate a report of coaches, quizzers and teams (this only grabs coaches and quizzers with a complete registration)
  def coaches_quizzers_teams
    @participant_registrations = ParticipantRegistration.all(:conditions => 'registration_type = "Quizzer" or registration_type = "Coach"', :order => 'first_name asc, last_name asc')
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
      elsif (params['group_leader'] == '-7')
        group_leader_name = 'Representative'
        file_name = 'representative'
        participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-7)
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
      sheet1[1,8] = 'Housing'
      for i in 8..12
        sheet1.row(1).set_format(i,group_header_format)
      end
      sheet1[1,13] = 'Airline Information'
      for i in 13..19
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
      sheet1[2,column+=1] = 'Ministry Project'
      sheet1[2,column+=1] = 'Housing'
      sheet1[2,column+=1] = 'Housing June 28th'
      sheet1[2,column+=1] = 'Housing June 29th'
      sheet1[2,column+=1] = 'Roommate Preference 1'
      sheet1[2,column+=1] = 'Roommate Preference 2'
      sheet1[2,column+=1] = 'Airline Arrival Date'
      sheet1[2,column+=1] = 'Arrival Airline'
      sheet1[2,column+=1] = 'Arrival Flight Number'
      sheet1[2,column+=1] = 'Airline Departure Date'
      sheet1[2,column+=1] = 'Departure Airline'
      sheet1[2,column+=1] = 'Departure Flight Number'
      sheet1[2,column+=1] = 'Airport Shuttle'
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

        # ministry project
        if !participant.ministry_project.nil? or !participant.ministry_project_group.blank?
          assignment = ''
          assignment += participant.ministry_project ? participant.ministry_project.name : ''
          assignment += !participant.ministry_project_group.blank? ? ' - ' + participant.ministry_project_group : ''
          sheet1[pos,column+=1] = assignment
        else
          sheet1[pos,column+=1] = ''
        end
        
        # housing
        sheet1[pos,column+=1] = participant.housing
        sheet1[pos,column+=1] = participant.housing_saturday? ? 'YES' : ''
        sheet1[pos,column+=1] = participant.housing_sunday? ? 'YES' : ''
        sheet1[pos,column+=1] = participant.roommate_preference_1
        sheet1[pos,column+=1] = participant.roommate_preference_2
        
        # airline information
        sheet1[pos,column+=1] = participant.airline_arrival_date
        sheet1[pos,column+=1] = participant.arrival_airline
        sheet1[pos,column+=1] = participant.arrival_flight_number
        sheet1[pos,column+=1] = participant.airline_departure_date
        sheet1[pos,column+=1] = participant.departure_airline
        sheet1[pos,column+=1] = participant.departure_flight_number
        sheet1[pos,column+=1] = participant.airport_transportation? ? 'YES' : ''
        
        # other stuff
        sheet1[pos,column+=1] = participant.medical_liability? ? 'YES' : ''
        sheet1[pos,column+=1] = '$' + participant.amount_due.to_s
        
        # should we highlight the amount due field?
        change_highlight = false
          if participant.amount_due > 0
            change_highlight = true
            column_highlight = column
          end
          
          # set format
          for i in 1..21
            sheet1.row(pos).set_format(i,data_format)
          end
          
          # update highlight of money owed (if needed)
          sheet1.row(pos).set_format(column_highlight,money_owed_format) if change_highlight
      
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
      sheet1.column(9).width = 10
      sheet1.column(10).width = 10
      sheet1.column(11).width = 30
      sheet1.column(12).width = 30
      sheet1.column(13).width = 20
      sheet1.column(14).width = 20
      sheet1.column(15).width = 20
      sheet1.column(16).width = 20
      sheet1.column(17).width = 20
      sheet1.column(18).width = 20
      sheet1.column(19).width = 10
      sheet1.column(20).width = 10
      sheet1.column(21).width = 10

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
      group_leaders.push(-7)

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
        elsif (leader == -7)
          group_leader_name = 'Representative'
          participants = ParticipantRegistration.ordered_by_last_name.by_group_leader(-7)
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
        sheet1[1,8] = 'Housing'
        for i in 8..12
          sheet1.row(1).set_format(i,group_header_format)
        end
        sheet1[1,13] = 'Airline Information'
        for i in 13..19
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
        sheet1[2,column+=1] = 'Ministry Project'
        sheet1[2,column+=1] = 'Housing'
        sheet1[2,column+=1] = 'Housing June 28th'
        sheet1[2,column+=1] = 'Housing June 29th'
        sheet1[2,column+=1] = 'Roommate Preference 1'
        sheet1[2,column+=1] = 'Roommate Preference 2'
        sheet1[2,column+=1] = 'Airline Arrival Date'
        sheet1[2,column+=1] = 'Arrival Airline'
        sheet1[2,column+=1] = 'Arrival Flight Number'
        sheet1[2,column+=1] = 'Airline Departure Date'
        sheet1[2,column+=1] = 'Departure Airline'
        sheet1[2,column+=1] = 'Departure Flight Number'
        sheet1[2,column+=1] = 'Airport Shuttle'
        sheet1[2,column+=1] = 'Medical Liability Received'
        sheet1[2,column+=1] = 'Amount Owed'
        sheet1.row(2).default_format = header_format

        # keep track of t-shirt numbers
        youth_small = 0
        youth_medium = 0
        youth_large = 0
        small = 0
        medium = 0
        large = 0
        x_large = 0
        xx_large = 0
        xxx_large = 0
        xxxx_large = 0
        xxxxx_large = 0
        undefined_size = 0
      
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
  
          # ministry project
          if !participant.ministry_project.nil? or !participant.ministry_project_group.blank?
            assignment = ''
            assignment += participant.ministry_project ? participant.ministry_project.name : ''
            assignment += !participant.ministry_project_group.blank? ? ' - ' + participant.ministry_project_group : ''
            sheet1[pos,column+=1] = assignment
          else
            sheet1[pos,column+=1] = ''
          end
          
          # housing
          sheet1[pos,column+=1] = participant.housing
          sheet1[pos,column+=1] = participant.housing_saturday? ? 'YES' : ''
          sheet1[pos,column+=1] = participant.housing_sunday? ? 'YES' : ''
          sheet1[pos,column+=1] = participant.roommate_preference_1
          sheet1[pos,column+=1] = participant.roommate_preference_2
          
          # airline information
          sheet1[pos,column+=1] = participant.airline_arrival_date
          sheet1[pos,column+=1] = participant.arrival_airline
          sheet1[pos,column+=1] = participant.arrival_flight_number
          sheet1[pos,column+=1] = participant.airline_departure_date
          sheet1[pos,column+=1] = participant.departure_airline
          sheet1[pos,column+=1] = participant.departure_flight_number
          sheet1[pos,column+=1] = participant.airport_transportation? ? 'YES' : ''
          
          # other stuff
          sheet1[pos,column+=1] = participant.medical_liability? ? 'YES' : ''
          sheet1[pos,column+=1] = '$' + participant.amount_due.to_s
          
          # should we highlight the amount due field?
          change_highlight = false
          if participant.amount_due > 0
            change_highlight = true
            column_highlight = column
          end
          
          # set format
          for i in 1..21
            sheet1.row(pos).set_format(i,data_format)
          end
          
          # update highlight of money owed (if needed)
          sheet1.row(pos).set_format(column_highlight,money_owed_format) if change_highlight

          # tabulate shirt size
          case participant.shirt_size
          when 'Youth Small'
            youth_small += 1
          when 'Youth Medium'
            youth_medium += 1
          when 'Youth Large'
            youth_large += 1
          when 'Small'
            small += 1
          when 'Medium'
            medium += 1
          when 'Large'
            large += 1
          when 'X-Large'
            x_large += 1
          when '2X-Large'
            xx_large += 1
          when '3X-Large'
            xxx_large += 1
          when '4X-Large'
            xxxx_large += 1
          when '5X-Large'
            xxxxx_large += 1
          else
            undefined_size += 1
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
        sheet1.column(9).width = 10
        sheet1.column(10).width = 10
        sheet1.column(11).width = 30
        sheet1.column(12).width = 30
        sheet1.column(13).width = 20
        sheet1.column(14).width = 20
        sheet1.column(15).width = 20
        sheet1.column(16).width = 20
        sheet1.column(17).width = 20
        sheet1.column(18).width = 20
        sheet1.column(19).width = 10
        sheet1.column(20).width = 10
        sheet1.column(21).width = 10

        # output shirt size counts
        pos += 2
        sheet1[pos,1] = "Youth Small"
        sheet1[pos,2] = youth_small
        sheet1[pos,3] = "X-Large"
        sheet1[pos,4] = x_large
        pos += 1
        sheet1[pos,1] = "Youth Medium"
        sheet1[pos,2] = youth_medium
        sheet1[pos,3] = "2X-Large"
        sheet1[pos,4] = xx_large
        pos += 1
        sheet1[pos,1] = "Youth Large"
        sheet1[pos,2] = youth_large
        sheet1[pos,3] = "3X-Large"
        sheet1[pos,4] = xxx_large
        pos += 1
        sheet1[pos,1] = "Small"
        sheet1[pos,2] = small
        sheet1[pos,3] = "4X-Large"
        sheet1[pos,4] = xxxx_large
        pos += 1
        sheet1[pos,1] = "Medium"
        sheet1[pos,2] = medium
        sheet1[pos,3] = "5X-Large"
        sheet1[pos,4] = xxxxx_large
        pos += 1
        sheet1[pos,1] = "Large"
        sheet1[pos,2] = large
        sheet1[pos,3] = "Undefined"
        sheet1[pos,4] = undefined_size
        
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
      sheet1[1,column+=1] = 'June 28th'
      sheet1[1,column+=1] = 'June 29th'
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

        sheet1[pos,column+=1] = participant.housing_saturday? ? 'Yes' : ''
      sheet1[pos,column+=1] = participant.housing_sunday? ? 'Yes' : ''

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
        sheet1[1,column+=1] = 'June 28th'
        sheet1[1,column+=1] = 'June 29th'
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

          sheet1[pos,column+=1] = participant.housing_saturday? ? 'Yes' : ''
          sheet1[pos,column+=1] = participant.housing_sunday? ? 'Yes' : ''

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
      elsif (params['group_leader'] == '-7')
        group_leader_name = 'Representative'
        file_name = 'representative'
        participants = ParticipantRegistration.by_group_leader(-7).ordered_by_building_room_last_name
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
      sheet1[1,column+=1] = 'June 28th'
      sheet1[1,column+=1] = 'June 29th'
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
        sheet1[pos,column+=1] = participant.housing_saturday? ? 'Yes' : ''
        sheet1[pos,column+=1] = participant.housing_sunday? ? 'Yes' : ''

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
      group_leaders.push(-7)

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
        elsif (leader == -7)
          group_leader_name = 'Representative'
          participants = ParticipantRegistration.by_group_leader(-7).ordered_by_building_room_last_name
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
        sheet1[1,column+=1] = 'June 28th'
        sheet1[1,column+=1] = 'June 29th'
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
          sheet1[pos,column+=1] = participant.housing_saturday? ? 'Yes' : ''
          sheet1[pos,column+=1] = participant.housing_sunday? ? 'Yes' : ''

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
       
    @participants = ParticipantRegistration.no_team
                         
    pos = 1
    @participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.formatted_registration_type
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.mobile_phone
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
    sheet1[0,column+=1] = 'June 28th'
    sheet1[0,column+=1] = 'June 29th'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.ordered_by_last_name

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
      sheet1[pos,column+=1] = participant.housing_saturday? ? 'Yes' : ''
      sheet1[pos,column+=1] = participant.housing_sunday? ? 'Yes' : ''
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
    sheet1[0,column+=1] = 'Special Need Details'

    sheet1.row(0).default_format = header_format

    participants = ParticipantRegistration.has_special_needs.ordered_by_last_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.gender
      sheet1[pos,column+=1] = participant.group_leader_name
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      sheet1[pos,column+=1] = participant.special_needs
      sheet1[pos,column+=1] = participant.special_needs_details
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 25
    sheet1.column(1).width = 10
    sheet1.column(2).width = 25
    sheet1.column(3).width = 25
    sheet1.column(4).width = 25
    sheet1.column(5).width = 100

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

    participants = ParticipantRegistration.by_registration_type('Event Staff').ordered_by_last_name

    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.mobile_phone
      sheet1[pos,column+=1] = participant.email
      sheet1[pos,column+=1] = !participant.district.nil? ? participant.district.name : ''
      pos += 1
    end

    # column widths
    sheet1.column(0).width = 25
    sheet1.column(1).width = 15
    sheet1.column(2).width = 30
    sheet1.column(3).width = 25

    book.write "#{RAILS_ROOT}/public/download/event_staff.xls"

    send_file "#{RAILS_ROOT}/public/download/event_staff.xls", :filename => "event_staff.xls"
  end
  
  # create a downloadable excel of participants who requested a shuttle, but don't have flight info
  def shuttle_no_flight_info
    self.shuttle ParticipantRegistration.needs_shuttle.no_flight_info, 'no_flight'
  end
  
  # create a downloadable excel of participants who requested a shuttle
  def shuttle_all
    self.shuttle ParticipantRegistration.needs_shuttle
  end
  
  # create a downloadable excel of participants who requested a shuttle
  def shuttle(participants=ParticipantRegistration.all,filename='all')
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
    sheet1[0,column+=1] = 'Airline Arrival Date'
    sheet1[0,column+=1] = 'Arrival Airline'
    sheet1[0,column+=1] = 'Arrival Flight Number'
    sheet1[0,column+=1] = 'Airline Departure Date'
    sheet1[0,column+=1] = 'Departure Airline'
    sheet1[0,column+=1] = 'Departure Flight Number'
    sheet1[0,column+=1] = 'Airport Shuttle'
    sheet1.row(0).default_format = header_format
                         
    pos = 1
    participants.each do |participant|
      column = 0
      sheet1[pos,column] = participant.full_name_reversed
      sheet1[pos,column+=1] = participant.formatted_registration_type
      sheet1[pos,column+=1] = participant.home_phone
      sheet1[pos,column+=1] = participant.mobile_phone
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

      # airline information
      sheet1[pos,column+=1] = participant.airline_arrival_date
      sheet1[pos,column+=1] = participant.arrival_airline
      sheet1[pos,column+=1] = participant.arrival_flight_number
      sheet1[pos,column+=1] = participant.airline_departure_date
      sheet1[pos,column+=1] = participant.departure_airline
      sheet1[pos,column+=1] = participant.departure_flight_number
      sheet1[pos,column+=1] = participant.airport_transportation? ? 'YES' : ''
        
      pos += 1
    end

    for i in 0..15
      sheet1.column(i).width = 30
    end

    book.write "#{RAILS_ROOT}/public/download/shuttle_#{filename}.xls"

    send_file "#{RAILS_ROOT}/public/download/shuttle_#{filename}.xls", :filename => "shuttle_#{filename}.xls"
  end
end