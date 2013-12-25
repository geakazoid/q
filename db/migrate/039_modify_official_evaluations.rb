class ModifyOfficialEvaluations < ActiveRecord::Migration
  def self.up
    # remove columns
    remove_column :evaluations, :level
    remove_column :evaluations, :rapport_quizzers
    remove_column :evaluations, :rapport_quizzers_explanation
    remove_column :evaluations, :rapport_coaches
    remove_column :evaluations, :rapport_coaches_explanation
    
    # add new columns
    add_column :evaluations, :levels, :text
    add_column :evaluations, :best_suited_level, :string
    add_column :evaluations, :interpersonal_skills, :text
    add_column :evaluations, :handles_conflict, :text
    add_column :evaluations, :content_judge_utilization, :text
    add_column :evaluations, :additional_comments, :text
  end

  def self.down
    # readd columns
    add_column :evaluations, :level, :string
    add_column :evaluations, :rapport_quizzers, :string
    add_column :evaluations, :rapport_quizzers_explanation, :text
    add_column :evaluations, :rapport_coaches, :string
    add_column :evaluations, :rapport_coaches_explanation, :text
    
    # remove new columns
    remove_column :evaluations, :levels
    remove_column :evaluations, :best_suited_level
    remove_column :evaluations, :interpersonal_skills
    remove_column :evaluations, :handles_conflict
    remove_column :evaluations, :content_judge_utilization
    remove_column :evaluations, :additional_comments
  end
end