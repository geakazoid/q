class UsersController < ApplicationController
  require "spreadsheet"

  # GET /users
  def index
    # grab all users
    @users = User.search(params[:q], {:page => current_page})

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # GET /users/:id
  def show
    raise ActiveRecord::RecordNotFound
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def edit
    if !params[:id].nil? and !admin?
      record_not_found
      return
    elsif !params[:id].nil? and admin?
      @user = User.find(params[:id])
    elsif current_user
      @user = current_user
    else
      record_not_found
      return
    end
  end
 
  def create
    logout_keeping_session!
    @user = User.new
    @user.attributes = params[:user]
    logger.debug("USER: " + @user.inspect)
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      
      # immediately register and activate this user
      @user.register!
      @user.activate!
      
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for registering!"
    else
      render :action => 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html {
        if @user.update_attributes(params[:user])
          if (@user == current_user)
            flash[:notice] = "Your account has been successfully updated."
          else
            flash[:notice] = "User account has been successfully updated."
          end
          redirect_to(account_path)
        else
          render :action => 'new'
        end
      }
    end
  end
  
  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.delete!
    flash[:notice] = 'User was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to(users_url) }
    end
  end

  # GET /users/1/activate_user
  def activate_user
    @user = User.find(params[:id])
    @user.activate!
    flash[:notice] = 'User was successfully activated.'

    respond_to do |format|
      format.html { redirect_to(users_url) }
    end
  end

  # create a downloadable excel file of users / registrations
  def download
    users = User.all(:order => 'last_name desc, first_name desc')
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    # write out headers
    sheet1[0,0] = 'First Name'
    sheet1[0,1] = 'Last Name'
    sheet1[0,2] = 'Email'
    sheet1[0,3] = 'Address'
    sheet1[0,4] = 'City'
    sheet1[0,5] = 'State'
    sheet1[0,6] = 'Zipcode'
    sheet1[0,7] = 'Communicate By Email'
    sheet1[0,8] = 'Agrees To Promotion'
    registerable_items = RegisterableItem.all
    i = 9
    registerable_items.each do |registerable_item|
      sheet1[0,i] = registerable_item.name
      i += 1
      sheet1[0,i] = registerable_item.name + ' Fee'
      i += 1
    end
    sheet1[0,i] = 'Total Fee'
    i += 1
    sheet1[0,i] = 'Created On'
    i += 1
    sheet1[0,i] = 'Updated On'
    
    pos = 1
    users.each do |user|
      grand_total = 0;
      sheet1[pos,0] = user.first_name
      sheet1[pos,1] = user.last_name
      sheet1[pos,2] = user.email
      sheet1[pos,3] = user.address.street
      sheet1[pos,4] = user.address.city
      sheet1[pos,5] = user.address.state
      sheet1[pos,6] = user.address.zipcode
      sheet1[pos,7] = user.communicate_by_email
      sheet1[pos,8] = user.registration.promotion_agree
      i = 9
      user.registration.registration_items.each do |registration_item|
        sheet1[pos,i] = registration_item.count
        i += 1
        item_total = (registration_item.count * registration_item.registerable_item.price_in_cents) / 100
        grand_total += item_total
        sheet1[pos,i] = item_total
        i += 1
      end
      sheet1[pos,i] = grand_total
      i += 1
      sheet1[pos,i] = user.created_at
      i += 1
      sheet1[pos,i] = user.updated_at
      pos = pos + 1
    end
    book.write "#{RAILS_ROOT}/public/download/registrations.xls"

    send_file "#{RAILS_ROOT}/public/download/registrations.xls", :filename => "registrations.xls"
  end
end
