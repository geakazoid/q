#require 'rest_client'
require 'json'

class PaymentsController < ApplicationController

  # GET /payments/new
  def new  
    if session[:team_registration]
      @team_registration = TeamRegistration.find(session[:team_registration][:id])
      @amount_in_cents = @team_registration.amount_in_cents
      @total_amount = @amount_in_cents / 100
    elsif session[:participant_registration]
      @participant_registration = ParticipantRegistration.find(session[:participant_registration][:id])
      @amount_in_cents = session[:participant_registration][:payment_amount]
      @total_amount = @amount_in_cents / 100
    else
      record_not_found and return
    end
    
    # create a session
    session[:payment] = Hash.new if session[:payment].nil?
    
    # find text for payments page
    @page = Page.find_by_label('New Payment Text')

    respond_to do |format|
      format.html
    end
  end
  
  # POST /payments
  def create
    @payment = Payment.new
    @payment.user = current_user
    @payment.attributes = params[:payment]
    
    if session[:participant_registration]
      @payment.details = session[:participant_registration][:details]
    end
    
    valid = false
    
    # only try to submit a payment if we need to actually pay
    if !@payment.zero_amount?
      if @payment.valid? and submit_payment
        valid = true
      end
    elsif @payment.valid?
      valid = true
    end
    
    if valid
      @payment.save
      
      if session[:team_registration]
        # mark the team_registration as paid
        @payment.team_registration.paid = true
        @payment.team_registration.audit_user = current_user
        @payment.team_registration.save
      elsif session[:participant_registration]
        # clean up participant registration
        clean_up_participant_registration
      end
      
      # deliver payment receipt to the entered email address
      if @payment.zero_amount?
        #PaymentMailer.deliver_zero_receipt(@payment,session)
      else
        #PaymentMailer.deliver_receipt(@payment,session)
      end
    end

    respond_to do |format|
      format.html {
        if valid
          if @payment.zero_amount?
            render :action => 'zero_receipt'
          else
            render :action => 'receipt'
          end
        else
          render :action => 'new'
        end
      }
    end
  end
  
  # submit a payment to convio
  def submit_payment

    begin
      # send data to convio
      @response = RestClient.post 'https://secure2.convio.net/cn/site/CRDonationAPI',
                    :"v" => "1.0",
                    :"api_key" => '2BwpTsmVwJhD7oa4',
                    :"form_id" => 16280,
                    :"level_id" => 17261,
                    :"method" => 'donate',
                    :"response_format" => 'json',
                    :"other_amount" => @payment.total_amount,
                    :"card_number" => @payment.credit_card_number,
                    :"card_cvv" => @payment.security_code,
                    :"card_exp_date_month" => @payment.expiration_month,
                    :"card_exp_date_year" => @payment.expiration_year,
                    :"billing.address.street1" => @payment.address,
                    :"billing.address.city" => @payment.city,
                    :"billing.address.state" => @payment.state,
                    :"billing.address.zip" => @payment.zipcode,
                    :"billing.address.country" => @payment.country,
                    :"billing.name.first" => @payment.first_name,
                    :"billing.name.last" => @payment.last_name,
                    :"donor.email" => @payment.email,
                    :"validate" => 'true',
                    #:"df_preview" => 'true',
                    :"offline_payment_method" => "check"
    rescue => e
      @response = e.response
    end
    
    # parse out the response from convio
    @result = JSON.parse(@response)
    
    # log the response from convio
    logger.info("CONVIO: " + @response)
    
    # add the response to the payment so we get the details back from convio
    @payment.response = @response
    
    if @result['donationResponse'].has_key? 'errors'
      @payment.errors.add_to_base(@result['donationResponse']['errors']['fieldError'])
      return false
   end

    return true
  end
  
  def clean_up_participant_registration
    @participant_registration = @payment.participant_registration
    @participant_registration.audit_user = current_user

    # reset all extras (unless they're being skipped)
    if session[:participant_registration][:skip_extras].nil?
      numeric_extras = ['num_extra_group_photos','num_dvd','num_extra_youth_small_shirts',
        'num_extra_youth_medium_shirts','num_extra_youth_large_shirts',
        'num_extra_small_shirts','num_extra_medium_shirts','num_extra_large_shirts',
        'num_extra_xlarge_shirts','num_extra_2xlarge_shirts','num_extra_3xlarge_shirts',
        'num_extra_4xlarge_shirts','num_extra_5xlarge_shirts','num_sv_tickets']

      # reset all numeric extras to nil (this clears the form for us)
      numeric_extras.each do |extra|
        eval("@participant_registration.#{extra} = nil")
      end

      # clear out extras fee (since we just paid it)
      @participant_registration.extras_fee = 0;
    end

    # find our registration fee
    registration_fee = @participant_registration.registration_fee

    # find out what's been paid already
    registration_paid = @participant_registration.paid_registration_amount * 100

    # get our discounts (if applicable)
    registration_discount = @participant_registration.registration_discount ? @participant_registration.registration_discount : 0

    # find out what's remaining to be paid
    registration_fee_remaining = registration_fee - registration_paid - registration_discount

    if registration_fee_remaining == 0
      @participant_registration.paid = true
    end

    # save our registration back to the database
    @participant_registration.save

    # update school registration paid status if exhibitor
    if @participant_registration.exhibitor?
      @participant_registration.school.paid = true
      @participant_registration.school.save
    end
  end
  
  def success
    @payment = Payment.new
    @payment.user = current_user
    @payment.first_name = params[:first_name]
    @payment.last_name = params[:last_name]
    @payment.email = params[:email]
    @payment.phone = params[:phone]
    @payment.address = params[:address]
    @payment.city = params[:city]
    @payment.state = params[:state]
    @payment.zipcode = params[:zip]
    @payment.country = params[:country]
    @payment.amount_in_cents = params[:amount_in_cents]
    @payment.transaction_id = params[:txn_id]
    @payment.response = 'confirmation code: ' + params[:confim_cd] + ', transaction_id: ' + params[:txn_id] + ', total_amount: ' + params[:total_amount]
        
    if session[:participant_registration]
      @payment.details = session[:participant_registration][:details]
      @payment.participant_registration_id = session[:participant_registration][:id]
    end
    
    if session[:team_registration]
      @payment.team_registration_id = session[:team_registration][:id]
    end
    
    @payment.save
      
    if session[:team_registration]
      # mark the team_registration as paid
      @payment.team_registration.paid = true
      @payment.team_registration.audit_user = current_user
      @payment.team_registration.save
    elsif session[:participant_registration]
      # clean up participant registration
      clean_up_participant_registration
    end
      
    # deliver payment receipt to the entered email address
    if @payment.zero_amount?
      #PaymentMailer.deliver_zero_receipt(@payment,session)
    else
      #PaymentMailer.deliver_receipt(@payment,session)
    end
    
    # add the payment to the session
    session[:payment_id] = @payment.id
    session[:transaction_id] = params[:txn_id]
    
    logger.info(@payment.inspect)
    
    respond_to do |format|
      format.html {
        redirect_to(receipt_payments_path)
      }
    end
  end
  
  def receipt
    @payment = Payment.find(session[:payment_id]) if session[:payment_id]
    
    respond_to do |format|
      format.html {
        if @payment.nil?
          redirect_to(root_path)
        end
      }
    end
  end
  
  def fail
    @reason = params['reason']
    @error = params['pageError']
    logger.info("Credit Card Payment Failure: Reason - " + @reason + " - pageError - " + @error)
    
    if @reason == 'FIELD_VALIDATION'
      flash[:error] = "There was an issue with processing your payment. Please check the required fields and try again."
    else
      flash[:error] = "An unknown error has occurred. Please try again later."
    end

    session[:payment] = Hash.new
    session[:payment][:first_name] = params[:first_name]
    session[:payment][:last_name] = params[:last_name]
    session[:payment][:email] = params[:email]
    session[:payment][:phone] = params[:phone]
    session[:payment][:address] = params[:address]
    session[:payment][:city] = params[:city]
    session[:payment][:state] = params[:state]
    session[:payment][:zip] = params[:zip]
    session[:payment][:country] = params[:country]

    respond_to do |format|
      format.html {
        redirect_to(new_payment_path)
      }
    end
  end

  def confirm
    if session[:team_registration]
      @team_registration = TeamRegistration.find(session[:team_registration][:id])
      if params['amount'].to_i == @team_registration.amount_in_cents
        redirect_to(confirm_team_registrations_url)
      else
        render "failure"
      end
    elsif session[:participant_registration]
      @participant_registration = ParticipantRegistration.find(session[:participant_registration][:id])
      logger.warn(params['amount'])
      if params['amount'].to_i == @participant_registration.amount_ordered * 100
        redirect_to(confirm_participant_registrations_url)
      else
        render "failure"
      end
    else
      render "failure"
    end
  end

  def failure
    respond_to do |format|
      format.html
    end
  end
end
