require 'json'
require 'digest/md5'

class TransactionsController < ApplicationController

  # GET /transactions/new
  def new
    # create a new transaction
    @transaction = Transaction.new
    @transaction.event = Event.active_event
    @transaction.user = current_user
    @first_name = nil
    @last_name = nil
    object_id = nil
    email = nil

    if session[:team_registration]
      @team_registration = TeamRegistration.find(session[:team_registration][:id])
      @transaction.fee = @team_registration.amount_in_cents / 100
      @transaction.team_registration = @team_registration
      @first_name = current_user.first_name
      @last_name = current_user.last_name
      object_id = @team_registration.id.to_s
      email = current_user.email
    elsif session[:participant_registration]
      @participant_registration = ParticipantRegistration.find(session[:participant_registration][:id])
      @transaction.fee = @participant_registration.amount_ordered
      @transaction.participant_registration = @participant_registration
      @first_name = current_user.first_name
      @last_name = current_user.last_name
      object_id = @participant_registration.id.to_s
      email = current_user.email
    elsif session[:payment]
      @payment = Payment.find(session[:payment][:id])
      @transaction.fee = @payment.fee
      @transaction.payment = @payment
      @first_name = @payment.first_name
      @last_name = @payment.last_name
      object_id = @payment.id.to_s
      email = @payment.email
    else
      record_not_found and return
    end

    if @transaction.fee > 0
      # generate a new transaction code
      @transaction.email = 'q20-' + Digest::MD5.hexdigest(object_id + Time.now.to_s)[0...4] + '-' + email
    else
      @transaction.email = email
      @transaction.complete = true

      if !@transaction.participant_registration.nil?
        # handle payment for a participant registration
        @transaction.participant_registration.paid = true
        @transaction.participant_registration.save(false)
      end

      if !@transaction.team_registration.nil?
        # handle payment for a team registration
        @transaction.team_registration.paid = true
        @transaction.team_registration.save(false)
      end
    end

    if @transaction.save
      # clean up the session
      session[:team_registration] = nil
      session[:participant_registration] = nil
      session[:payment] = nil

      respond_to do |format|
        if @transaction.fee > 0
          format.html
        else
          # send receipt email
          TransactionMailer.deliver_zero_receipt(@transaction)
          format.html { render :action => "new_no_payment" }
        end
      end
    end
  end

  # GET /transactions/webhook
  # POST /transactions/webhook
  def webhook
    if request.get?
      # return a 200. this is used to setup the webhook
      render :text => 'Webhook Endpoint'
    end

    if request.post?
      # log the json data for record keeping
      logger.info(request.raw_post)
      # handle json body
      raw_data = JSON.parse(request.raw_post)
      data = {}
      data['messageTime'] = raw_data['messageTime'].to_time.to_formatted_s(:long_ordinal)
      data['confirmation_number'] = raw_data['message'][0]['confirmationNumber']
      data['order_number'] = raw_data['message'][0]['orders'][0]['order_number']
      data['email'] = raw_data['message'][0]['email']
      data['fullname'] = raw_data['message'][0]['fullname']

      # use email to find correct transaction
      transaction = Transaction.find_by_email(data['email'])

      if !transaction.participant_registration.nil?
        # handle payment for a participant registration
        transaction.participant_registration.paid = true
        transaction.participant_registration.save(false)
      end

      if !transaction.team_registration.nil?
        # handle payment for a team registration
        transaction.team_registration.paid = true
        transaction.team_registration.save(false)
      end

      if !transaction.payment.nil?
        # handle payment for a team registration
        transaction.payment.paid = true
        transaction.payment.save(false)
      end

      # mark the transaction as complete
      transaction.complete = true
      transaction.save

      # send receipt email
      TransactionMailer.deliver_receipt(transaction, data)

      # return success message
      render :text => 'Success'
    end
  end
end