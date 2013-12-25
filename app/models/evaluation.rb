class Evaluation < ActiveRecord::Base
  belongs_to :official
  belongs_to :district
  
  before_create :create_key
  
  # serialize / unserialize levels array when saving / loading from the database
  serialize :levels
  
  # validations
  validates_presence_of :name, :on => :update
  validates_presence_of :district, :on => :update
  validates_presence_of :levels, :on => :update
  validates_presence_of :best_suited, :on => :update
  validates_presence_of :reading, :on => :update
  validates_presence_of :reading_explanation, :on => :update
  validates_presence_of :ruling, :on => :update
  validates_presence_of :ruling_explanation, :on => :update
  validates_presence_of :knowledge_material, :on => :update
  validates_presence_of :knowledge_material_explanation, :on => :update
  validates_presence_of :knowledge_ruling, :on => :update
  validates_presence_of :knowledge_ruling_explanation, :on => :update
  validates_presence_of :interpersonal_skills, :on => :update
  validates_presence_of :handles_conflict, :on => :update
  validates_presence_of :content_judge_utilization, :on => :update
  validates_presence_of :position, :on => :update

  # mark this evaluation as complete
  def mark_complete
    self.complete = true
    self.save
  end
  
  # initialize roles if this is a new object or no roles have been selected
  def after_initialize
    self.levels ||= Array.new
  end
  
  private

  # create a key before saving. this is used for referencing the object
  def create_key
    self.key = Digest::MD5.hexdigest(self.official_id.to_s + self.sent_to_email)
  end

end