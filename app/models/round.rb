class Round < ActiveRecord::Base
  belongs_to :quiz_division
  belongs_to :room
  has_many :round_teams
  has_many :round_quizzers
  has_many :actions, :order => "question asc, action asc"

  def questions
    sql = ActiveRecord::Base.connection()
    count = sql.execute("select count(distinct(question)) from actions where round_id = " + id.to_s).fetch_row
    count[0].to_i
  end

  # return true if this round has good data / false otherwise
  def check_data
    # make sure we have some teams
    if self.round_teams.size < 2
      puts('round did not pass check: not enough round teams')
      return false
    end

    questions = Array.new

    self.actions.each do |action|
      questions[action.question] = Array.new if questions[action.question].nil?
      questions[action.question].push(action.action)
    end

    # check that we have the right number of actions per question
    #puts(questions.inspect)
    questions.each do |question_number|
      #puts(question_number.inspect)
      unless question_number.nil?
        question_number.sort!
        last_action = question_number[question_number.size - 1]
        if last_action > question_number.size - 1
          #puts(question_number.size.to_s + ' actions received : ' +  (last_action.to_i + 1).to_s + ' action expected')
          puts('round did not pass check: insufficient actions')
          return false
        end
      end
    end

    # everything looks pretty good so return true
    return true
  end

  def from_prelims?
    return true if self.number =~ /\d+/
    return false
  end
end
