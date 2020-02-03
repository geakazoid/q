require 'json'
require 'digest/md5'

class TransactionsController < ApplicationController

  # GET /transactions/new
  def new
    # create a new transaction
    @transaction = Transaction.new
    @transaction.event = Event.active_event
    @transaction.user = current_user
    object_id = nil

    if session[:team_registration]
      @team_registration = TeamRegistration.find(session[:team_registration][:id])
      @transaction.fee = @team_registration.amount_in_cents / 100
      @transaction.team_registration = @team_registration
      object_id = @team_registration.id.to_s
    elsif session[:participant_registration]
      @participant_registration = ParticipantRegistration.find(session[:participant_registration][:id])
      @transaction.fee = @participant_registration.amount_ordered
      @transaction.participant_registration = @participant_registration
      # generate a new transaction code
      object_id = @participant_registration.id.to_s
    else
      record_not_found and return
    end

    # generate a new transaction code
    @transaction.email = 'q20-' + Digest::MD5.hexdigest(object_id + Time.now.to_s)[0...4] + '-' + current_user.email

    respond_to do |format|
      if @transaction.save
        format.html
      end
    end
  end
end