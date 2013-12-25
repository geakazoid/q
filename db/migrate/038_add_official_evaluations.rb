class AddOfficialEvaluations < ActiveRecord::Migration
  def self.up
    # create an evaluations table
    create_table :evaluations do |t|
      t.string :key
      t.string :sent_to_name
      t.string :sent_to_email
      t.belongs_to :official
      t.boolean :complete
      t.string :name
      t.belongs_to :district
      t.string :level
      t.string :best_suited
      t.text :where_observed
      t.string :reading
      t.text :reading_explanation
      t.string :ruling
      t.text :ruling_explanation
      t.string :knowledge_material
      t.text :knowledge_material_explanation
      t.string :knowledge_ruling
      t.text :knowledge_ruling_explanation
      t.string :rapport_quizzers
      t.text :rapport_quizzers_explanation
      t.string :rapport_coaches
      t.text :rapport_coaches_explanation
      t.string :position
      t.timestamps
    end
  end

  def self.down
    # drop our new evaluations
    drop_table :evaluations
  end
end