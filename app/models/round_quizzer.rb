class RoundQuizzer < ActiveRecord::Base
  belongs_to :round
  belongs_to :quizzer
end