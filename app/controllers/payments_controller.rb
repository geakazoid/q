require 'digest/md5'

class PaymentsController < ApplicationController

  # GET /payments/new
  def new
    @payment = Payment.new
    respond_to do |format|
      format.html
    end
  end
  
  # POST /payments
  def create
    @payment = Payment.new
    @payment.attributes = params[:payment]
    @payment.identifier = Digest::MD5.hexdigest(Time.now.to_s)[0...8]
    
    respond_to do |format|
      if @payment.save
        # send new payment email
        PaymentMailer.deliver_new(@payment)
        flash[:notice] = 'Payment email was sent to user.'
        format.html { redirect_to(new_payment_path) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # GET /payment/:identifier
  def email_payment
    @payment = Payment.find_by_identifier(params[:identifier])
    
    # prepare hash for storing participant registration values
    session[:payment] = Hash.new

    # store all values in the session
    session[:payment][:id] = @payment.id

    respond_to do |format|
      # send to transactions controller
      format.html { redirect_to(AppConfig.site_url + '/transactions/new') }
    end
  end
end
