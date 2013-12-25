class ModifyQuizTeams < ActiveRecord::Migration
  def self.up
    # add an original column so we can see the line comin from qview
    add_column :quiz_teams, :manual_rank, :integer

    # copy manual rank for just District Experienced Pool A
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '4' and pool = 'A'", :order => "rank asc")
    teams.each do |team|
      team.manual_rank = team.rank
    end
  end

  def self.down
    # remove our new original field
    remove_column :quiz_teams, :manual_rank
  end
end
