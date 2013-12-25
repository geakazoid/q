class Import
  require 'open-uri'

  def self.import_rounds
    file = ARGV.shift
    File.open(file).each { |line|
      columns = line.split(',')
      c_division = columns[2].gsub(/"/,'').strip
      c_room = columns[3].gsub(/"/,'').strip
      c_round = columns[4].gsub(/"/,'').strip
      
      division = QuizDivision.find_by_name(c_division)
      if (division.nil?)
        division = QuizDivision.new
        division.name = c_division
        division.save
      end
      
      room = Room.find(:first, :conditions => "name = '#{c_room}'")
      if (room.nil?)
        room = Room.new
        room.name = c_room
        room.save
      end
      
      round = Round.find(:first, :conditions =>"room_id = #{room.id} and number = '#{c_round}'")
      if (round.nil?)
        round = Round.new
        round.number = c_round
        round.room = room
        round.division = division
        round.save
      end
    }
  end

  def self.single_qview_import
    @rounds_to_audit = Array.new

    url = 'http://video.q2010.org/getevents?limit=1000&division=Decades&round=206'
    puts(url)
    open(url,'User-Agent' => 'Ruby-Wget').each { |line|
      if line[0,7] == 'sha1sum'
        next
      end
      if line[0,7] == 'LastKey'
        new_last_key = line.split('=')[1]
        last_key = new_last_key.to_i if new_last_key.to_i != 0
        break
      end
      # output a line for a visual view of what's going on
      puts line
      # import our line
      import_line(line)
    }
    audit_rounds
  end

  def self.import_room_from_qview
    @rounds_to_audit = Array.new

    room = ARGV.shift
    room = room.gsub("\"", "").gsub(" ", "%20")

    url = 'http://video.q2010.org/getevents?room=' + room
    puts(url)
    open(url,'User-Agent' => 'Ruby-Wget').each { |line|
      if line[0,7] == 'sha1sum'
        next
      end
      if line[0,7] == 'LastKey'
        new_last_key = line.split('=')[1]
        last_key = new_last_key.to_i if new_last_key.to_i != 0
        break
      end
      # output a line for a visual view of what's going on
      puts line
      # import our line
      import_line(line)
    }
    audit_rounds
  end

  def self.import_division_from_qview
    @rounds_to_audit = Array.new

    division = ARGV.shift
    division = division.gsub("\"", "").gsub(" ", "%20")

    url = 'http://video.q2010.org/getevents?division=' + division
    puts(url)
    open(url,'User-Agent' => 'Ruby-Wget').each { |line|
      if line[0,7] == 'sha1sum'
        next
      end
      if line[0,7] == 'LastKey'
        new_last_key = line.split('=')[1]
        last_key = new_last_key.to_i if new_last_key.to_i != 0
        break
      end
      # output a line for a visual view of what's going on
      puts line
      # import our line
      import_line(line)
    }
    audit_rounds
  end

  def self.import_from_qview
    @rounds_to_audit = Array.new
    last_key = 0 
    while true
      puts('grabbing new data')
      url = 'http://video.q2010.org/getevents?limit=100&rcvts=2010-07-02+05:00:00&tournament=Q2010&ikey=' + (last_key.to_i + 1).to_s
      puts(url)
      open(url,'User-Agent' => 'Ruby-Wget').each { |line|
        if line[0,7] == 'sha1sum'
          next
        end
        if line[0,7] == 'LastKey'
          new_last_key = line.split('=')[1]
          last_key = new_last_key.to_i if new_last_key.to_i != 0
          break
        end
        # output a line for a visual view of what's going on
        puts line
        # import our line
        import_line(line)
      }
      audit_rounds
    end
  end

  # import teams into the database
  def self.import_teams
    # variables
    line_number = 1

    file = ARGV.shift
    File.open(file).each { |line|
      line_number += 1
      puts(line)
      columns = line.split(',')
      c_team = columns[0].strip
      c_division = columns[1].strip
      c_pool = columns[2].chomp.strip

      division = QuizDivision.find_by_name(c_division)

      quiz_team = QuizTeam.find(:first, :conditions => "name = '#{c_team}' and quiz_division_id = '#{division.id}'")
      if (quiz_team.nil?)
        quiz_team = QuizTeam.new
        quiz_team.name = c_team
        quiz_team.quiz_division = division
        quiz_team.pool = c_pool
        quiz_team.save
      end
    }
  end

  # setup division, room, and round variables based upon the line being parsed
  def self.setup_quiz(c_division, c_room, c_round)
    @division = QuizDivision.find_by_name(c_division)
    @room = Room.find(:first, :conditions => "name = '#{c_room}'")

    if @room.nil? or @division.nil?
      return false
    end

    @round = Round.find(:first, :conditions =>"room_id = '#{@room.id}' and quiz_division_id = '#{@division.id}' and number = '#{c_round}'")

    if (!@division.nil? && !@room.nil? && @round.nil?)
      round = Round.new
      round.number = c_round
      round.room = @room
      round.quiz_division = @division
      round.save
    end
  end

  # import a line from quiz machine
  def self.import_line(line)
    columns = line.split(',')
    c_tournament = columns[1].gsub(/'/,'')
    c_division = columns[2].gsub(/'/,'')
    c_room = columns[3].gsub(/'/,'')
    c_round = columns[4].gsub(/'/,'')
    c_question = columns[5].gsub(/'/,'')
    c_action = columns[6].gsub(/'/,'')
    c_data = columns[7].gsub(/'/,'')
    c_team = columns[8].gsub(/'/,'')
    c_seat = columns[9].gsub(/'/,'')
    c_identifier = columns[10].gsub(/'/,'')
    c_timestamp = columns[13].gsub(/'/,'')

    # setup our quiz with default values
    if setup_quiz(c_division, c_room, c_round)
      return
    end

    # skip this line if it's a quiz we don't care about
    if (c_tournament != 'Q2010' or @division.nil? or @room.nil? or @round.nil?)
      return
    end

    # save this round for later auditing
    @rounds_to_audit.push(@round)

    if (c_identifier == 'TN')
      quiz_team = QuizTeam.find(:first, :conditions => "name = '#{c_data}' and quiz_division_id = '#{@division.id}'")
      puts(quiz_team.inspect)
      puts(@round.inspect)
      if (!quiz_team.nil?)
        round_team = RoundTeam.find(:first, :conditions => "quiz_team_id = '#{quiz_team.id}' and round_id = '#{@round.id}'")
	puts("###########################################################" + round_team.inspect)
        if (round_team.nil?)
	  puts('creating a new round_team' + c_data)
          round_team = RoundTeam.new
          round_team.quiz_team = quiz_team
          round_team.round = @round
          round_team.position = c_team
          round_team.save
        end
      end
    end

    if (c_identifier == 'QN')
      round_team = RoundTeam.find(:first, :conditions => "position = '#{c_team}' and round_id = '#{@round.id}'")
      unless (round_team.nil?)
        quizzer = Quizzer.find(:first, :conditions => "name = '#{c_data}' and quiz_division_id = '#{@division.id}'")
        if quizzer.nil?
          quizzer = Quizzer.new
          quizzer.name = c_data
          quizzer.quiz_division = @division
          quizzer.quiz_team = round_team.quiz_team
          quizzer.save
        end

        round_quizzer = RoundQuizzer.find(:first, :conditions => "quizzer_id = '#{quizzer.id}' and round_id = '#{@round.id}'")
        if (round_quizzer.nil?)
          round_quizzer = RoundQuizzer.new
          round_quizzer.quizzer = quizzer
          round_quizzer.round = @round
          round_quizzer.save
        end
      end
    end

    # insert / update everything into actions table
    action = Action.find(:first, :conditions => "round_id = #{@round.id} and question = #{c_question} and action = #{c_action}")
    if (action.nil?)
      action = Action.new
      action.round = @round
      action.question = c_question
      action.action = c_action
      action.save
    end
    action.data = c_data
    action.qm_team = c_team
    action.seat = c_seat
    action.identifier = c_identifier
    action.action_time = c_timestamp
    action.original = line
    if (action.identifier == 'QN' or action.identifier == 'TC' or action.identifier == 'TE' or action.identifier == 'BC' or action.identifier == 'BE' or action.identifier == 'SS' or action.identifier == 'SC')
      action.quizzer = Quizzer.find(:first, :conditions => "name = '#{c_data}' and quiz_division_id = '#{@division.id}'")
    end
    if (action.identifier == 'TN')
      action.quiz_team = QuizTeam.find(:first, :conditions => "name = '#{c_data}' and quiz_division_id = '#{@division.id}'")
    end
    action.save
  end

  # import quizzes from a csv file
  # this will need to be changed to support a remote url call
  def self.import_quizzes
    @rounds_to_audit = Array.new
    # variables
    line_number = 1
    
    file = ARGV.shift
    File.open(file).each { |line|
      line_number += 1
      import_line(line)
    }

    # audit the rounds we just imported data for
    audit_rounds
  end

  def self.audit_one
    @rounds_to_audit = Array.new
    @rounds_to_audit.push(Round.find(1642))
    audit_rounds
  end

  def self.audit_all
    @rounds_to_audit = Round.all(:conditions => "quiz_division_id = 7 and id != 1284")
    audit_rounds
  end

  # audit rounds and figure out placement, score, etc.
  def self.audit_rounds
    puts('auditing rounds')
    # if passed in quizzes is nil we audit all quizzes in the database
    if @rounds_to_audit.nil?
      puts('no rounds to audit')
      return
    end

    # only audit a round once
    @rounds_to_audit.uniq!

    puts('auditing the following rounds...')
    puts(@rounds_to_audit.inspect)

    @rounds_to_audit.each do |round|
      puts('auditing round: ' + round.id.to_s)

      # skip the round if our data is bad
      if !round.check_data
        next
      end

      # overtime points
      overtime_points = 3

      teams = Array.new
      round.actions.each do |action|
        if (action.identifier == 'TN')
          teams[action.qm_team] = Hash.new
          teams[action.qm_team]['name'] = action.data
          teams[action.qm_team]['place'] = 0
          teams[action.qm_team]['correct_quizzers'] = Array.new
          teams[action.qm_team]['quizzers'] = Array.new
          teams[action.qm_team]['questions'] = Hash.new
          teams[action.qm_team]['scoring'] = Hash.new
          teams[action.qm_team]['score'] = 0
          teams[action.qm_team]['correct'] = 0
          teams[action.qm_team]['errors'] = 0
          teams[action.qm_team]['timeouts'] = 0
          teams[action.qm_team]['fouls'] = 0
          teams[action.qm_team]['running_score'] = Array.new
          teams[action.qm_team]['bonus_penalty'] = Array.new
          teams[action.qm_team]['overtime_points'] = 0
          teams[action.qm_team]['overruled_challenges'] = 0
        elsif (action.identifier == 'QN')
          if (!teams[action.qm_team].nil?)
            if (teams[action.qm_team]['questions'][action.data].nil?)
              teams[action.qm_team]['questions'][action.data] = Array.new
              teams[action.qm_team]['scoring'][action.data] = Hash.new
              teams[action.qm_team]['scoring'][action.data]['points'] = 0;
              teams[action.qm_team]['scoring'][action.data]['correct'] = 0;
              teams[action.qm_team]['scoring'][action.data]['errors'] = 0;
            end
            if (teams[action.qm_team]['quizzers'][action.seat].nil? or action.question == 1)
              teams[action.qm_team]['quizzers'][action.seat] = action.data
            end
          end
        elsif (action.identifier == 'TC')
          if (action.question < 21)
            # jump - correct
	    puts(action.qm_team)
	    puts(action.data)
	    puts(action.question)
	    puts(action.inspect)
            teams[action.qm_team]['questions'][action.data][action.question] = '20'
            teams[action.qm_team]['scoring'][action.data]['correct'] += 1
            teams[action.qm_team]['scoring'][action.data]['points'] += 20
            teams[action.qm_team]['score'] += 20
            teams[action.qm_team]['correct'] += 1
            # new quizzer with a correct toss up!
            correct_quizzers_before = teams[action.qm_team]['correct_quizzers'].size
            teams[action.qm_team]['correct_quizzers'].push(teams[action.qm_team]['scoring'][action.data])
            teams[action.qm_team]['correct_quizzers'].uniq!
            correct_quizzers_after = teams[action.qm_team]['correct_quizzers'].size
            if (correct_quizzers_after > correct_quizzers_before and correct_quizzers_after >= 3)
              teams[action.qm_team]['score'] += 10
              teams[action.qm_team]['bonus_penalty'][action.question] = '10'
            end
            # quizout?
            if (teams[action.qm_team]['scoring'][action.data]['correct'] == 4 and teams[action.qm_team]['scoring'][action.data]['errors'] == 0)
              teams[action.qm_team]['scoring'][action.data]['points'] += 10
              teams[action.qm_team]['score'] += 10
              teams[action.qm_team]['bonus_penalty'][action.question] = '10'
            end

            teams[action.qm_team]['running_score'][action.question] = teams[action.qm_team]['score']
          else
            teams[action.qm_team]['overtime_points'] = overtime_points
            overtime_points -= 1
            teams[action.qm_team]['questions'][action.data][21] = "20"
          end
        elsif (action.identifier == 'TE')
          if (action.question < 21)
            # jump - error
            teams[action.qm_team]['questions'][action.data][action.question] = 'E'
            teams[action.qm_team]['scoring'][action.data]['errors'] += 1
            teams[action.qm_team]['errors'] += 1
            if (teams[action.qm_team]['scoring'][action.data]['errors'] == 3)
              teams[action.qm_team]['scoring'][action.data]['points'] -= 10
              teams[action.qm_team]['score'] -= 10
              teams[action.qm_team]['running_score'][action.question] = teams[action.qm_team]['score']
              teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
            elsif (teams[action.qm_team]['errors'] >= 5)
              teams[action.qm_team]['score'] -= 10
              teams[action.qm_team]['running_score'][action.question] = teams[action.qm_team]['score']
              teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
            elsif (action.question > 15)
              teams[action.qm_team]['score'] -= 10
              teams[action.qm_team]['running_score'][action.question] = teams[action.qm_team]['score']
              teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
            end
          else
            teams[action.qm_team]['overtime_points'] = 0 - overtime_points
            overtime_points -= 1
            teams[action.qm_team]['questions'][action.data][21] = "E"
          end
        elsif (action.identifier == 'BC')
          # bonus - correct
          teams[action.qm_team]['questions'][action.data][action.question] = 'B/+'
          teams[action.qm_team]['score'] += 10
          teams[action.qm_team]['running_score'][action.question] = teams[action.qm_team]['score']
          teams[action.qm_team]['bonus_penalty'][action.question] = '10'
        elsif (action.identifier == 'BE')
          # jump - error
          teams[action.qm_team]['questions'][action.data][action.question] = 'B/-'
        elsif (action.identifier == 'TO')
          teams[action.qm_team]['timeouts'] += 1
        elsif (action.identifier == 'FC' or action.identifier == 'F-')
          teams[action.qm_team]['fouls'] += 1
          if (teams[action.qm_team]['fouls'] >= 2)
            teams[action.qm_team]['score'] -= 10
            teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
            teams[action.qm_team]['running_score'][action.question] = teams[action.qm_team]['score']
          end
        elsif (action.identifier == 'C-')
          teams[action.qm_team]['overruled_challenges'] += 1
          if (teams[action.qm_team]['overruled_challenges'] >= 2)
            teams[action.qm_team]['score'] -= 10
            teams[action.qm_team]['bonus_penalty'][action.question] = '-10'
            teams[action.qm_team]['running_score'][action.question] = teams[action.qm_team]['score']
          end
        end
      end

      # fill in team placements
      if (teams.size == 2)
        if (teams[0]['score'] + teams[0]['overtime_points'] > teams[1]['score'] + teams[1]['overtime_points'])
          teams[0]['place'] = 1
          teams[1]['place'] = 2
        else
          teams[0]['place'] = 2
          teams[1]['place'] = 1
        end
      elsif (teams.size == 3)
        if (teams[0]['score'] + teams[0]['overtime_points'] > teams[1]['score'] + teams[1]['overtime_points'] and teams[0]['score'] + teams[0]['overtime_points'] > teams[2]['score'] + teams[2]['overtime_points'])
          teams[0]['place'] = 1
          if (teams[1]['score'] + teams[1]['overtime_points'] > teams[2]['score'] + teams[2]['overtime_points'])
            teams[1]['place'] = 2
            teams[2]['place'] = 3
          else
            teams[1]['place'] = 3
            teams[2]['place'] = 2
          end
        elsif (teams[1]['score'] + teams[1]['overtime_points'] > teams[0]['score'] + teams[0]['overtime_points'] and teams[1]['score'] + teams[1]['overtime_points'] > teams[2]['score'] + teams[2]['overtime_points'])
          teams[1]['place'] = 1
          if (teams[0]['score'] + teams[0]['overtime_points'] > teams[2]['score'] + teams[2]['overtime_points'])
            teams[0]['place'] = 2
            teams[2]['place'] = 3
          else
            teams[0]['place'] = 3
            teams[2]['place'] = 2
          end
        else
          teams[2]['place'] = 1
          if (teams[0]['score'] + teams[0]['overtime_points'] > teams[1]['score'] + teams[1]['overtime_points'])
            teams[0]['place'] = 2
            teams[1]['place'] = 3
          else
            teams[0]['place'] = 3
            teams[1]['place'] = 2
          end
        end
      end

      # save stats for teams to the database using round teams
      round_team_0 = RoundTeam.find(:first, :conditions => "position = '0' and round_id = '#{round.id}'")
      puts(round_team_0.inspect)
      round_team_0.place = teams[0]['place']
      round_team_0.score = teams[0]['score']
      round_team_0.save
      
      round_team_1 = RoundTeam.find(:first, :conditions => "position = '1' and round_id = '#{round.id}'")
      puts(round_team_1.inspect)
      round_team_1.place = teams[1]['place']
      round_team_1.score = teams[1]['score']
      round_team_1.save
      
      if teams.size == 3
        #round_team_2 = RoundTeam.find(:first, :conditions => "position = '2' and round_id = '#{round.id}'")
        #puts(round_team_2.inspect)
        #round_team_2.place = teams[2]['place']
        #round_team_2.score = teams[2]['score']
        #round_team_2.save
      end

      # save stats for quizzers to the database using round quizzers
      teams.each do |team|
        team['scoring'].each do |name,data|
          quizzer = Quizzer.find(:first, :conditions => "name = '#{name}' and quiz_division_id = '#{round.quiz_division.id}'")
	  if !quizzer.nil?
            round_quizzer = RoundQuizzer.find(:first, :conditions => "quizzer_id = '#{quizzer.id}' and round_id = '#{round.id}'")
            if (round_quizzer.nil?)
              puts('round_quizzer was missing...recreated!')
              round_quizzer = RoundQuizzer.new
              round_quizzer.quizzer = quizzer
              round_quizzer.round = round
            end
            round_quizzer.score = data['points']
            round_quizzer.total_correct = data['correct']
            round_quizzer.total_errors = data['errors']
            round_quizzer.save
	  end
        end
      end

      # see if this round is complete
      if (round.questions >= 20)
        round.complete = true
        round.save
      end
    end

    # reset rounds to audit
    @rounds_to_audit = Array.new
  end

  # update the team rankings using completed rounds
  def self.update_team_rankings
    puts('updating team rankings')
    divisions = Array.new
    new_division = QuizDivision.find(7)
    divisions.push(new_division)
    divisions.each do |division|
      rounds = division.complete_rounds
      teams = division.quiz_teams

      teams.each do |team|
        team.reset_stats
        team.save
      end

      # update stats for each team
      rounds.each do |round|
        puts('updating information from round...')
        puts(round.inspect)
        num_teams = round.round_teams.size
        round.round_teams.each do |round_team|
          round_team.quiz_team.rounds += 1
	  puts(round_team.inspect)
          round_team.quiz_team.total_points += round_team.score
          if num_teams == 2
            round_team.quiz_team.wins += 1 if round_team.place == 1
            round_team.quiz_team.losses += 1 if round_team.place == 2
          elsif num_teams == 3
            round_team.quiz_team.wins += 2 if round_team.place == 1
            round_team.quiz_team.wins += 1 if round_team.place == 2
            round_team.quiz_team.losses += 1 if round_team.place == 2
            round_team.quiz_team.losses += 2 if round_team.place == 3
          end
          round_team.quiz_team.save
        end
      end
    end

    divisions = Array.new
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '1'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '2' and pool = 'A'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '2' and pool = 'B'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '3'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '4' and pool = 'A'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '4' and pool = 'B'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '5'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '6'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '7'", :order => "wins desc, losses asc")
    divisions.push(teams)

    divisions.each do |teams|
      rank = 1
      last_team = nil
      ties = Array.new
      tied_for = nil
      teams.each do |team|
        if !last_team.nil? and last_team.record == team.record
          ties.push(last_team)
          ties.push(team)
          tied_for = last_team.rank if tied_for.nil?
        else
          # deal with a tie that may have surfaced
          unless tied_for.nil?
            break_ties(ties,tied_for)
            ties = Array.new
            tied_for = nil
          end
        end
        team.rank = rank
        team.save
        rank += 1
        last_team = team
      end

      # did we end with a tie?
      unless tied_for.nil?
        break_ties(ties,tied_for)
        ties = Array.new
        tied_for = nil
      end
    end
  end

  # update decades team rankings
  def self.update_decades_team_rankings
    puts('updating team rankings')
    divisions = QuizDivision.all(:conditions => "id in (2,4,7)")
    divisions.each do |division|
      rounds = division.complete_rounds
      teams = division.quiz_teams

      teams.each do |team|
        team.reset_stats
        team.save
      end

      # update stats for each team
      rounds.each do |round|
        puts('updating information from round...')
        puts(round.inspect)
        num_teams = round.round_teams.size
        round.round_teams.each do |round_team|
          round_team.quiz_team.rounds += 1
          round_team.quiz_team.total_points += round_team.score
          if num_teams == 2
            round_team.quiz_team.wins += 1 if round_team.place == 1
            round_team.quiz_team.losses += 1 if round_team.place == 2
          elsif num_teams == 3
            round_team.quiz_team.wins += 2 if round_team.place == 1
            round_team.quiz_team.wins += 1 if round_team.place == 2
            round_team.quiz_team.losses += 1 if round_team.place == 2
            round_team.quiz_team.losses += 2 if round_team.place == 3
          end
          round_team.quiz_team.save
        end
      end
    end

    divisions = Array.new
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '1'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '2' and pool = 'A'", :order => "wins desc, losses asc")
    divisions.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '2' and pool = 'B'", :order => "wins desc, losses asc")
    divisions.push(teams)
    #teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '3'", :order => "wins desc, losses asc")
    #divisions.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '4' and pool = 'A'", :order => "wins desc, losses asc")
    divisions.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '4' and pool = 'B'", :order => "wins desc, losses asc")
    divisions.push(teams)
    teams = QuizTeam.find(:all, :conditions => "quiz_division_id = '7'", :order => "wins desc, losses asc")
    divisions.push(teams)

    divisions.each do |teams|
      rank = 1
      last_team = nil
      ties = Array.new
      tied_for = nil
      teams.each do |team|
        if !last_team.nil? and last_team.record == team.record
          ties.push(last_team)
          ties.push(team)
          tied_for = last_team.rank if tied_for.nil?
        else
          # deal with a tie that may have surfaced
          unless tied_for.nil?
            break_ties(ties,tied_for)
            ties = Array.new
            tied_for = nil
          end
        end
        team.rank = rank
        team.save
        rank += 1
        last_team = team
      end

      # did we end with a tie?
      unless tied_for.nil?
        break_ties(ties,tied_for)
        ties = Array.new
        tied_for = nil
      end
    end
  end

  # update the individual rankings using completed rounds
  def self.update_individual_rankings
    puts('updating individual rankings')
    divisions = QuizDivision.all
    divisions.each do |division|
      quizzers = division.quizzers

      quizzers.each do |quizzer|
        quizzer.reset_stats
        quizzer.save
      end

      rounds = Round.all(:conditions => "quiz_division_id = '#{division.id}' and complete = 1 and id < 1516")

      # update stats for each quizzer
      rounds.each do |round|
        round.round_quizzers.each do |round_quizzer|
          round_quizzer.quizzer.actual_rounds += 1
          round_quizzer.quizzer.points += round_quizzer.score
          round_quizzer.quizzer.total_correct += round_quizzer.total_correct
          round_quizzer.quizzer.total_errors += round_quizzer.total_errors
          round_quizzer.quizzer.save
        end
      end
    end

    divisions = QuizDivision.all
    divisions.each do |division|
      division.quizzers.each do |quizzer|
        quizzer.calculate_average
      end

      rank = 1
      division.ordered_quizzers.each do |quizzer|
        quizzer.rank = rank
        quizzer.save
        rank += 1
      end
    end
  end

  # break any ties between teams
  def self.break_ties(teams,tied_for)
    puts('breaking a tie...')
    puts(teams.inspect)
    # remove duplicates
    teams.uniq!

    teams.sort! {|a,b| a.beat?(b) }

    rank = tied_for
    teams.each do |team|
      team.rank = rank
      team.save
      rank += 1
    end
  end
end
