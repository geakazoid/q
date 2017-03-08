class RegistrationsController < ApplicationController
  layout 'registrations'

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def cvent
    respond_to do |format|
      format.html # cvent.html.erb
    end
  end
end
