class MinistryProjectsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => false

  skip_before_filter :verify_authenticity_token, :only => :auto_complete_for_ministry_project_group

  def auto_complete_for_ministry_project_group
    typed = ''
    params['participant_registration'].each do |key,value|
      id = key
      typed = value['ministry_project_group']
    end

    @ministry_project_groups = Array.new
    unless params['ministry_project_id'].blank? or typed.blank?
      sql = "select ministry_project_group,count(ministry_project_group) as count from participant_registrations where ministry_project_id = #{params['ministry_project_id']} and ministry_project_group like '%#{typed}%' group by ministry_project_group;"
      r = ActiveRecord::Base.connection.execute(sql)

      r.each_hash do |row|
        @ministry_project_groups.push(row)
      end
    end
  end
end