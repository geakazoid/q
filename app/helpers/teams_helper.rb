module TeamsHelper
  def fix_name(team_name)
    team_name.gsub(/\#/,'').gsub(/\//,'_').gsub(/"/,'').gsub(/'/,'')
  end
end