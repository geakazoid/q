class Action < ActiveRecord::Base
  belongs_to :round
  belongs_to :quizzer
  belongs_to :quiz_team
end