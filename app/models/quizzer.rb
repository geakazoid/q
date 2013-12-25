class Quizzer < ActiveRecord::Base
  require 'decimal'

  belongs_to :quiz_division
  belongs_to :quiz_team
  has_many :actions

  # reset all statistics to zero
  def reset_stats
    self.actual_rounds = 0
    self.points = 0
    self.average = 0.0
    self.total_correct = 0
    self.total_errors = 0
    self.rank = 0
    
    # total quizzes
    total_quizzes = 0
    self.quiz_team.round_teams.each do |round_team|
      total_quizzes += 1 if round_team.round.complete? and round_team.round.from_prelims?
    end
    self.total_rounds = total_quizzes
  end

  def calculate_average
    unless self.total_rounds == 0
      self.average = Decimal(self.points) / Decimal(self.total_rounds)
      self.save
    end
  end
end
