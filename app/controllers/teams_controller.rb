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
    if @team.nil? or (@team.team_registration.user != current_user)
      @output = "Something went horribly wrong."
    end
    
    if @team.regional_team?
      @quizzers = ParticipantRegistration.find(:all,
                                               :conditions => 'district_id in (select id from districts where region_id = ' + @team.team_registration.user.district.region_id.to_s + ') and (registration_type = "Quizzer" or registration_type = "Student")',
                                               :order => 'first_name asc, last_name asc')
    else
      @quizzers = ParticipantRegistration.find(:all,
                                               :conditions => 'district_id = ' + @team.team_registration.user.district_id.to_s + ' and (registration_type = "Quizzer" or registration_type = "Student")',
                                               :order => 'first_name asc, last_name asc')
    end
    
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  def update
    @team = Team.find(params[:id])
    
    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Team updated successfully.'
        format.html { redirect_to(user_team_registrations_url(current_user)) }
      else
        @quizzers = ParticipantRegistration.find(:all,
                                             :conditions => 'district_id = ' + current_user.district_id.to_s + ' and registration_type = "quizzer"',
                                             :order => 'first_name asc, last_name asc')
        format.html { render :action => "edit" }
      end
    end
  end
end