class EvaluationsController < ApplicationController
  require 'spreadsheet'
  
  before_filter :login_required, :except => [:show_from_key,:update]

  # GET /evaluation/:key
  def show_from_key
    @evaluation = Evaluation.find_by_key(params[:key])
    @evaluation.name = @evaluation.sent_to_name unless @evalution.nil? or @evaluation.sent_to_name.blank?

    respond_to do |format|
      format.html {
        if @evaluation.nil? or @evaluation.official.nil?
          render 'evaluations/invalid'
        elsif @evaluation.complete?
          render 'evaluations/complete'
        else
          render 'evaluations/edit'
        end
      }
    end
  end
  
  def update
    @evaluation = Evaluation.find(params[:id])
    
    record_not_found and return if @evaluation.key != params[:evaluation][:key]

    respond_to do |format|
      if @evaluation.update_attributes(params[:evaluation])
        @evaluation.mark_complete
        # deliver evaluation completion notification to admins and official admins
        EvaluationMailer.deliver_complete_evaluation(@evaluation, ['tolson27@gmail.com'], current_user)
        format.html
      else
        @errors = true
        format.html {
          render 'evaluations/edit'
        }
      end
    end
  end
end
