class StatisticsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :tinymce_upload

  # GET /pages
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /statistics/:name
  def show
    @statistic = Statistic.find_by_name(params[:name])
    record_not_found and return if @statistic.nil?
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end