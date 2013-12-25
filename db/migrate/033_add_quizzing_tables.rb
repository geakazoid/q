class AddQuizzingTables < ActiveRecord::Migration
  def self.up
    # quiz_actions (this stores events that happen during a round)
    create_table :actions do |t|
      t.belongs_to :round, :null => false
      t.integer :question, :null => false
      t.integer :action, :null => false
      t.string :data, :default => "", :null => false
      t.integer :qm_team
      t.integer :seat
      t.string :identifier, :default => "", :null => false
      t.belongs_to :quiz_team
      t.belongs_to :quizzer
      t.datetime :action_time
      t.timestamps
    end

    add_index :actions, [:round_id, :question, :action], :unique => true

    create_table :quiz_divisions do |t|
      t.string :name
      t.timestamps
    end

    create_table :rounds do |t|
      t.belongs_to :room
      t.belongs_to :quiz_division
      t.string :number
      t.integer :questions, :default => 0
      t.boolean :visible, :default => true
      t.boolean :complete
    end

    create_table :round_teams do |t|
      t.belongs_to :round
      t.belongs_to :quiz_team
      t.integer :position
      t.integer :place
      t.integer :score
    end

    create_table :round_quizzers do |t|
      t.belongs_to :round
      t.belongs_to :quizzer
      t.integer :score, :default => 0
      t.integer :total_correct, :default => 0
      t.integer :total_errors, :default => 0
    end

    create_table :quiz_teams do |t|
      t.belongs_to :quiz_division
      t.string :name
      t.string :pool
      t.integer :rounds, :default => 0
      t.integer :wins, :default => 0
      t.integer :losses, :default => 0
      t.integer :total_points, :default => 0
      t.integer :rank, :default => 0
    end

    create_table :quizzers do |t|
      t.belongs_to :quiz_division
      t.belongs_to :quiz_team
      t.string :name
      t.integer :total_rounds, :default => 0
      t.integer :actual_rounds, :default => 0
      t.integer :points, :default => 0
      t.decimal :average, :precision => 8, :scale => 2, :default => 0.0
      t.integer :total_correct, :default => 0
      t.integer :total_errors, :default => 0
      t.integer :rank, :default => 0
    end

    # add default quiz divisions
    QuizDivision.create(:name => 'Local Novice')
    QuizDivision.create(:name => 'Local Experienced')
    QuizDivision.create(:name => 'District Novice')
    QuizDivision.create(:name => 'District Experienced')
    QuizDivision.create(:name => 'Regional A')
    QuizDivision.create(:name => 'Regional B')
    QuizDivision.create(:name => 'Decades')
  end

  def self.down
    drop_table :actions
    drop_table :quiz_teams
    drop_table :quizzers
    drop_table :quiz_divisions
    drop_table :rounds
    drop_table :round_teams
    drop_table :round_quizzers
  end
end