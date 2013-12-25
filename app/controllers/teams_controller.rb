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
end