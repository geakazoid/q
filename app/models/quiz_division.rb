class QuizDivision < ActiveRecord::Base
  has_many :rounds
  has_many :complete_rounds, :class_name => 'Round', :conditions => 'complete = 1'
  has_many :quiz_teams, :order => "name asc"
  has_many :ordered_teams, :class_name => 'QuizTeam', :order => "wins desc, losses asc"
  has_many :quizzers
  has_many :ordered_quizzers, :class_name => 'Quizzer', :order => "average desc, total_errors asc"
end