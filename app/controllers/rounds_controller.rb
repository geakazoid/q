class RoundsController < ApplicationController
  layout 'empty'

  def index
    @rounds = Round.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def recent
    @rounds = Round.all(:conditions => "number in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','BB','CC','DD','EE','FF','GG','HH','II','JJ','KK','LL','MM','NN','OO','PP','QQ','RR','SS','TT','UU','VV','WW','XX','YY','ZZ')", :order => "quiz_division_id asc, number asc")

    # refresh page
    @refresh = true

    render :layout => "application"
  end

  def actions
    @round = Round.find(params[:id])

    respond_to do |format|
      format.html # actions.html.erb
    end
  end

  def show
    # overtime points
    @overtime_points = 3

    @round = Round.find(params[:id])
    @room = @round.room
    @division = @round.quiz_division
    @teams = Array.new
    @round.actions.each do |action|
      if (action.identifier == 'TN')
        @teams[action.qm_team] = Hash.new
        @teams[action.qm_team]['name'] = action.data
        @teams[action.qm_team]['place'] = 0
        @teams[action.qm_team]['correct_quizzers'] = Array.new
        @teams[action.qm_team]['quizzers'] = Array.new
        @teams[action.qm_team]['questions'] = Hash.new
        @teams[action.qm_team]['scoring'] = Hash.new
        @teams[action.qm_team]['score'] = 0
        @teams[action.qm_team]['correct'] = 0
        @teams[action.qm_team]['errors'] = 0
        @teams[action.qm_team]['timeouts'] = 0
        @teams[action.qm_team]['fouls'] = 0
        @teams[action.qm_team]['running_score'] = Array.new
        @teams[action.qm_team]['bonus_penalty'] = Array.new
        @teams[action.qm_team]['overtime_points'] = 0
        @teams[action.qm_team]['overruled_challenges'] = 0
      elsif (action.identifier == 'QN')
        if (!@teams[action.qm_team].nil?)
          if (@teams[action.qm_team]['questions'][action.data].nil?)
            @teams[action.qm_team]['questions'][action.data] = Array.new
            @teams[action.qm_team]['scoring'][action.data] = Hash.new
            @teams[action.qm_team]['scoring'][action.data]['points'] = 0;
            @teams[action.qm_team]['scoring'][action.data]['correct'] = 0;
            @teams[action.qm_team]['scoring'][action.data]['errors'] = 0;
          end
          if (@teams[action.qm_team]['quizzers'][action.seat].nil? or action.question == 1)
            @teams[action.qm_team]['quizzers'][action.seat] = action.data
          end
        end
      elsif (action.identifier == 'TC')
        if (action.question < 21)
          # jump - correct
          logger.info("Question: " + action.question.to_s + " : " + "Action: " + action.action.to_s)
          logger.info(@teams[action.qm_team]['questions'])
          @teams[action.qm_team]['questions'][action.data][action.question] = '20'
          @teams[action.qm_team]['scoring'][action.data]['correct'] += 1
          @teams[action.qm_team]['scoring'][action.data]['points'] += 20
          @teams[action.qm_team]['score'] += 20
          @teams[action.qm_team]['correct'] += 1
          # new quizzer with a correct toss up!
          correct_quizzers_before = @teams[action.qm_team]['correct_quizzers'].size
          @teams[action.qm_team]['correct_quizzers'].push(@teams[action.qm_team]['scoring'][action.data])
          @teams[action.qm_team]['correct_quizzers'].uniq!
          correct_quizzers_after = @teams[action.qm_team]['correct_quizzers'].size
          if (correct_quizzers_after > correct_quizzers_before and correct_quizzers_after >= 3)
            @teams[action.qm_team]['score'] += 10
            @teams[action.qm_team]['bonus_penalty'][action.question] = '10'
          end
          # quizout?
          if (@teams[action.qm_team]['scoring'][action.data]['correct'] == 4 and @teams[action.qm_team]['scoring'][action.data]['errors'] == 0)
            @teams[action.qm_team]['scoring'][action.data]['points'] += 10
            @teams[action.qm_team]['score'] += 10
            @teams[action.qm_team]['bonus_penalty'][action.question] = '10'
          end
        
          @teams[action.qm_team]['running_score'][action.question] = @teams[action.qm_team]['score']
        else
          @teams[action.qm_team]['overtime_points'] = @overtime_points
          @overtime_points -= 1
          @teams[action.qm_team]['questions'][action.data][21] = "20"
        end
      elsif (action.identifier == 'TE')
        if (action.question < 21)
          # jump - error
          @teams[action.qm_team]['questions'][action.data][action.question] = 'E'
          @teams[action.qm_team]['scoring'][action.data]['errors'] += 1
          @teams[action.qm_team]['errors'] += 1
          if (@teams[action.qm_team]['scoring'][action.data]['errors'] == 3)
            @teams[action.qm_team]['scoring'][action.data]['points'] -= 10
            @teams[action.qm_team]['score'] -= 10
            @teams[action.qm_team]['running_score'][action.question] = @teams[action.qm_team]['score']
            @teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
          elsif (@teams[action.qm_team]['errors'] >= 5)
            @teams[action.qm_team]['score'] -= 10
            @teams[action.qm_team]['running_score'][action.question] = @teams[action.qm_team]['score']
            @teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
          elsif (action.question > 15)
            @teams[action.qm_team]['score'] -= 10
            @teams[action.qm_team]['running_score'][action.question] = @teams[action.qm_team]['score']
            @teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
          end
        else
          @teams[action.qm_team]['overtime_points'] = 0 - @overtime_points
          @overtime_points -= 1
          @teams[action.qm_team]['questions'][action.data][21] = "E"
        end
      elsif (action.identifier == 'BC')
        # bonus - correct
        @teams[action.qm_team]['questions'][action.data][action.question] = 'B/+'
        @teams[action.qm_team]['score'] += 10
        @teams[action.qm_team]['running_score'][action.question] = @teams[action.qm_team]['score']
        @teams[action.qm_team]['bonus_penalty'][action.question] = '10'
      elsif (action.identifier == 'BE')
        # jump - error
        @teams[action.qm_team]['questions'][action.data][action.question] = 'B/-'
      elsif (action.identifier == 'TO')
        @teams[action.qm_team]['timeouts'] += 1
      elsif (action.identifier == 'FC' or action.identifier == 'F-')
        @teams[action.qm_team]['fouls'] += 1
        if (@teams[action.qm_team]['fouls'] >= 2)
          @teams[action.qm_team]['score'] -= 10
          @teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
          @teams[action.qm_team]['running_score'][action.question] = @teams[action.qm_team]['score']
        end
      elsif (action.identifier == 'C-')
        @teams[action.qm_team]['overruled_challenges'] += 1
        if (@teams[action.qm_team]['overruled_challenges'] >= 2)
          @teams[action.qm_team]['score'] -= 10
          @teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
          @teams[action.qm_team]['running_score'][action.question] = @teams[action.qm_team]['score']
        end
      end
      @last_action = action
    end
    
    # fill in team placements
    if (@teams.size == 2)
      if (@teams[0]['score'] + @teams[0]['overtime_points'] > @teams[1]['score'] + @teams[1]['overtime_points'])
        @teams[0]['place'] = '1st'
        @teams[1]['place'] = '2nd'
      else
        @teams[0]['place'] = '2nd'
        @teams[1]['place'] = '1st'
      end
    elsif (@teams.size == 3)
      if (@teams[0]['score'] + @teams[0]['overtime_points'] > @teams[1]['score'] + @teams[1]['overtime_points'] and @teams[0]['score'] + @teams[0]['overtime_points'] > @teams[2]['score'] + @teams[2]['overtime_points'])
        @teams[0]['place'] = '1st'
        if (@teams[1]['score'] + @teams[1]['overtime_points'] > @teams[2]['score'] + @teams[2]['overtime_points'])
          @teams[1]['place'] = '2nd'
          @teams[2]['place'] = '3rd'
        else
          @teams[1]['place'] = '3rd'
          @teams[2]['place'] = '2nd'
        end
      elsif (@teams[1]['score'] + @teams[1]['overtime_points'] > @teams[0]['score'] + @teams[0]['overtime_points'] and @teams[1]['score'] + @teams[1]['overtime_points'] > @teams[2]['score'] + @teams[2]['overtime_points'])
        @teams[1]['place'] = '1st'
        if (@teams[0]['score'] + @teams[0]['overtime_points'] > @teams[2]['score'] + @teams[2]['overtime_points'])
          @teams[0]['place'] = '2nd'
          @teams[2]['place'] = '3rd'
        else
          @teams[0]['place'] = '3rd'
          @teams[2]['place'] = '2nd'
        end
      else
        @teams[2]['place'] = '1st'
        if (@teams[0]['score'] + @teams[0]['overtime_points'] > @teams[1]['score'] + @teams[1]['overtime_points'])
          @teams[0]['place'] = '2nd'
          @teams[1]['place'] = '3rd'
        else
          @teams[0]['place'] = '3rd'
          @teams[1]['place'] = '2nd'
        end
      end
    end

    if !@round.complete?
      # refresh page
      @refresh = true
    end
  end
end
