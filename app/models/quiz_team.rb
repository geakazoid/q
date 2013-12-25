class QuizTeam < ActiveRecord::Base
  belongs_to :quiz_division
  has_many :quizzers
  has_many :actions
  has_many :round_teams

  # reset all statistics to zero
  def reset_stats
    self.rounds = 0
    self.wins = 0
    self.losses = 0
    self.total_points = 0
    self.rank = 0
  end

  # string representation of this team's record
  def record
    wins.to_s + '-' + losses.to_s
  end

  # return whether this team beat another team in head to head competition
  # used for sorting
  def beat?(team)
    my_rounds = Array.new
    their_rounds = Array.new

    self.round_teams.each do |round_team|
      my_rounds.push(round_team.round_id)
    end

    team.round_teams.each do |round_team|
      their_rounds.push(round_team.round_id)
    end

    intersect = my_rounds & their_rounds

    if (intersect.size == 0)
      # these teams have never faced each other
      return 0
    end
    
    round = Round.find(intersect[0])

    # the round we're looking at isn't complete, so we can't use it
    unless round.complete?
      return 0
    end

    my_round_team = round.round_teams.find_by_quiz_team_id(self.id)
    their_round_team = round.round_teams.find_by_quiz_team_id(team.id)

    logger.info('tie between...')
    logger.info(my_round_team.inspect)
    logger.info(their_round_team.inspect)

    if my_round_team.place > their_round_team.place
      return 1
    else
      return -1
    end
  end
end
