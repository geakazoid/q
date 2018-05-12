class TeamsController < ApplicationController

  # GET /teams
  def index
    # find all of our divisions
    @le = Division.find_by_name('Local Experienced')
    @ln = Division.find_by_name('Local Novice')
    @de = Division.find_by_name('District Experienced')
    @dn = Division.find_by_name('District Novice')
    @ra = Division.find_by_name('Regional A')
    @rb = Division.find_by_name('Regional B')

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def edit
    @team = Team.find(params[:id])
    
    @quizzers = self.available_quizzers(@team)
    
    # add in quizzers that are already on the team
    @quizzers = @quizzers + @team.participant_registrations
    @quizzers = @quizzers.uniq
    
    # create a list of districts with matching quizzers for display
    @districts = Hash.new
    @quizzers.each do |quizzer|
      @districts[quizzer.district.name] = Array.new if @districts[quizzer.district.name].nil?
      @districts[quizzer.district.name].push(quizzer)
    end
    @districts.keys.sort
    
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  def update
    @team = Team.find(params[:id])
    
    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Team updated successfully.'
        format.html { 
          if admin? and current_user != @team.team_registration.user
            redirect_to(team_registrations_url())
          else
            redirect_to(user_team_registrations_url(current_user))
          end
        }
      else
        @quizzers = self.available_quizzers(@team)

        # add in quizzers that are already on the team
        @quizzers = @quizzers + @team.participant_registrations
        @quizzers = @quizzers.uniq

        # create a list of districts with matching quizzers for display
        @districts = Hash.new
        @quizzers.each do |quizzer|
          @districts[quizzer.district.name] = Array.new if @districts[quizzer.district.name].nil?
          @districts[quizzer.district.name].push(quizzer)
        end
        @districts.keys.sort
        format.html { render :action => "edit" }
      end
    end
  end

  def available_quizzers(team)
    if params[:show_all] && admin?
      quizzers = ParticipantRegistration.find(:all,
                                               :joins => :district,
                                               :conditions => '(registration_type = "Quizzer" or registration_type = "Student") and paid = 1 and event_id = ' + Event.active_event.id.to_s,
                                               :order => 'districts.name desc, first_name asc, last_name asc')
    elsif @team.regional_team?
      quizzers = ParticipantRegistration.find(:all,
                                               :conditions => 'district_id in (select id from districts where region_id = ' + team.team_registration.user.district.region_id.to_s + ') and (registration_type = "Quizzer" or registration_type = "Student") and paid = 1 and event_id = ' + Event.active_event.id.to_s,
                                               :order => 'first_name asc, last_name asc')
    else
      quizzers = ParticipantRegistration.find(:all,
                                               :conditions => 'district_id = ' + team.team_registration.user.district_id.to_s + ' and (registration_type = "Quizzer" or registration_type = "Student") and paid = 1 and event_id = ' + Event.active_event.id.to_s,
                                               :order => 'first_name asc, last_name asc')
    end

    quizzers
  end
end
