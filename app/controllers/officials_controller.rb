class OfficialsController < ApplicationController
  require 'spreadsheet'
  
  before_filter :login_required

  # GET /officials
  def index
    if params[:user_id]
      @officials = Official.find(:all, :conditions => "user_id = #{params[:user_id]}", :order => "first_name asc")
      @user = User.find(params[:user_id])
      @title = "My Official Registrations"
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin? and !official_admin?
      @officials = Official.find(:all)
      @title = "Official Registrations"
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /officials/:id
  def show
    @official = Official.find(params[:id])
  end

  # GET /officials/new
  def new
    @official = Official.new
    @official.user = current_user
    @districts = District.find(:all, :order => "name")
    
    # find the text for the officials registration page
    @page = Page.find_by_label('Register Officials Text')

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /officials/:id/edit
  # GET /users/:user_id/officials/:id/edit
  def edit
    @official = Official.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
      # if the users don't match we shouldn't be here
      record_not_found and return if @user != current_user and !admin? and !official_admin?
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin? and !official_admin?
    end

    if (!@official.complete?)
      @districts = District.find(:all, :order => "name")
      @divisions = Division.find(:all)
    end

    respond_to do |format|
      format.html {
        render "officials/admin/edit" if admin? and !params[:user_id]
      }
    end
  end

  # POST /officials
  def create
    @official = Official.new(params[:official])
    if (params[:official][:user_id].nil?)
      @user = @official.user = current_user
    else
      @user = @official.user
    end
    @official.creator = current_user

    respond_to do |format|
      if @official.save
        # deliver new official registration notification
        OfficialMailer.deliver_new_registration(@official, (admin_emails + official_admin_emails).uniq, current_user)
        OfficialMailer.deliver_new_confirmation(@official, current_user)
        # deliver default evaluations
        send_default_evaluations
        format.js {
          flash[:notice] = 'You have successfully registered "' + @official.full_name + '" as an official. '
          flash[:notice] << 'You will receive confirmation of this via email and someone will contact you shortly regarding your registration.'
          render :update do |page|
            page.redirect_to new_official_path()
          end
        }
      else
        format.js { render :action => 'new' }
      end
    end
  end

  # PUT /officials/:id
  # PUT /users/:user_id/officials/:id
  def update
    @official = Official.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
      # if the users don't match we shouldn't be here
      record_not_found and return if @user != current_user and !admin? and !official_admin?

      @official.attributes = params[:official]
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin? and !official_admin?

      if @official.complete?
        @official.amount = params[:official]['amount']
        params[:official].delete('amount')
      end
      @official.attributes = params[:official]
    end

    if !@official.complete?
      # update amounts
      update_amounts
    end

    @official.audit_user = current_user

    respond_to do |format|
      if @official.save
        if !@user.nil?
          case params[:commit]
          when "Submit and Pay"
            # add official to the session
            generate_convio_url
            session[:official_id] = @official.id
            format.html { redirect_to(@convio_url) }
          when "Save For Later"
            flash[:notice] = 'Official Registration saved successfully. It can be edited later on the team registrations page. This can be accessed by using the right sidebar.'
            format.html { redirect_to(user_officials_path(@user)) }
          when "Update Registration"
            flash[:notice] = 'Official Registration updated successfully.'
            format.html { redirect_to(user_officials_path(@user)) }
          end
        else
          # this is an admin update
          flash[:notice] = 'Official Registration was successfully updated.'
          format.html { redirect_to(officials_path) }
        end
      else
        if !@user.nil?
          if (!@official.complete?)
            @districts = District.find(:all, :order => "name")
            @divisions = Division.find(:all)
          end
          format.html { render :action => "edit" }
        else
          format.html { render "officials/admin/edit" }
        end
      end
    end
  end

  # DELETE /officials/:id
  def destroy
    @official = Official.find(params[:id])
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      # if we aren't an admin we shouldn't be here
      record_not_found and return if !admin? and !official_admin?
    end

    # destroy the team registration
    @official.destroy

    flash[:notice] = 'Official Registration deleted successfully.'

    respond_to do |format|
      format.html {
        if params[:user_id]
          redirect_to(user_officials_url(@user))
        else
          redirect_to(officials_url)
        end
      }
    end
  end
  
  # POST /officials/:id/send_evaluation
  # send an evaluation for this official to a third party
  def send_evaluation
    
    if (!params[:resend])
      # check and make sure this evaluation hasn't already been sent
      return if Evaluation.find(:first, :conditions => "official_id = #{params[:id]} and sent_to_email = '#{params[:sent_to_email]}'")
    end
    
    # create a new evaluation
    @evaluation = Evaluation.new
    @evaluation.sent_to_name = params[:sent_to_name]
    @evaluation.sent_to_email = params[:sent_to_email]
    @evaluation.official_id = params[:id]
    @evaluation.save
    
    # send our evaluation email
    EvaluationMailer.deliver_new_evaluation(@evaluation, current_user)
    
    @id_to_update = params[:id_to_update]
    
    
    respond_to do |format|
      format.js # send_evaluation.js.rjs
    end
  end
  
  private
  
  # send default evaluations to the official's district and regional directors
  def send_default_evaluations
    # create a new evaluation for the district director
    unless @official.district.nil? or @official.district.email.empty?
      # create a new evaluation
      @district_evaluation = Evaluation.new
      @district_evaluation.sent_to_name = @official.district.director
      @district_evaluation.sent_to_email = @official.district.email
      @district_evaluation.official = @official
      @district_evaluation.save
      
      # send our evaluation email
      EvaluationMailer.deliver_new_evaluation(@district_evaluation, current_user)
    end
    
    # create a new evaluation for the regional director
    unless @official.district.nil? or @official.district.region.nil? or @official.district.region.email.empty?
      # create a new evaluation
      @region_evaluation = Evaluation.new
      @region_evaluation.sent_to_name = @official.district.region.director
      @region_evaluation.sent_to_email = @official.district.region.email
      @region_evaluation.official = @official
      @region_evaluation.save
      
      # send our evaluation email
      EvaluationMailer.deliver_new_evaluation(@region_evaluation, current_user)
    end
  end
end