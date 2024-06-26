class PasswordsController < ApplicationController
  def new
    @password = Password.new
  end

  def create
    @password = Password.new(params[:password])
    @password.user = User.find_by_email(@password.email)
    
    if @password.save
      PasswordMailer.deliver_forgot_password(@password)
      flash[:notice] = "A link to change your password has been sent to #{@password.email}."
      redirect_to :action => :new
    else
      flash[:error] = "#{@password.email} is not a valid account."
      render :action => :new
    end
  end

  def reset
    begin
      @user = Password.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.now]).user
    rescue
      flash[:notice] = 'The change password URL you visited is either invalid or expired.'
      redirect_to new_password_path
    end    
  end

  def update_after_forgetting
    @user = Password.find_by_reset_code(params[:reset_code]).user
      
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    
    error = false
    error = true if @user.password != @user.password_confirmation
    error = true if @user.password.blank?
    
    if !error
      @user.save false
      flash[:notice] = 'Your password was successfully updated.'
      redirect_to login_path
    else
      flash[:error] = 'Your password is not valid or your entries do not match. Please try again.'
      redirect_to :action => :reset, :reset_code => params[:reset_code]
    end
  end
  
  def update
    @password = Password.find(params[:id])

    if @password.update_attributes(params[:password])
      flash[:notice] = 'Your password was successfully updated.'
      redirect_to(@password)
    else
      render :action => :edit
    end
  end
end
