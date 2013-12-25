class StatsController < ApplicationController

  # GET /stats
  def index
    # for teams
    @teams = Array.new
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '1'", :order => "rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '2' and pool = 'A'", :order => "rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '2' and pool = 'B'", :order => "rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '3'", :order => "rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '4' and pool = 'A'", :order => "manual_rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '4' and pool = 'B'", :order => "rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '5'", :order => "rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '6'", :order => "rank asc", :limit => 5)
    @teams.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '7'", :order => "rank asc", :limit => 5)
    @teams.push(teams)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /stats/:id/team?pool=:pool
  def team
    if params[:id] == '4' and params[:pool] == 'A'
      @teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '#{params[:id]}' and pool = '#{params[:pool]}'", :order => "manual_rank asc")
    else
      @teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '#{params[:id]}' and pool = '#{params[:pool]}'", :order => "rank asc")
    end

    respond_to do |format|
      format.html # team.html.erb
    end
  end

  # GET /stats/:id/individual?pool=:pool
  def individual
    @quizzers = Quizzer.find(:all, :conditions => "quiz_division_id = '#{params[:id]}'", :order => "rank asc")

    respond_to do |format|
      format.html # individual.html.erb
    end
  end
end