class EquipmentRegistrationsController < ApplicationController

  before_filter :login_required

  # GET /equipment_registrations
  def index
    if params[:user_id]
      @equipment_registrations = EquipmentRegistration.find(:all, :conditions => "user_id = #{params[:user_id]}")
      @user = User.find(params[:user_id])
    else
      # if we aren't an admin or equipment_admin we shouldn't be here
      record_not_found and return if !admin? and !equipment_admin?
      @equipment_registrations = EquipmentRegistration.find(:all)
    end
    
    if @user.nil?
      @title = 'All Equipment Registrations'
    elsif @user == current_user
      @title = 'My Equipment Registrations'
    else
      @title = 'Equipment Registrations for ' + @user.fullname
    end

    # equipment counts
    @laptops = Equipment.find_all_by_equipment_type('laptop')
    @interface_boxes = Equipment.find_all_by_equipment_type('interface_box')
    @pads = Equipment.find_all_by_equipment_type('pads')
    @monitors = Equipment.find_all_by_equipment_type('monitor')
    @power_strips = Equipment.find_all_by_equipment_type('power_strip')
    @extension_cords = Equipment.find_all_by_equipment_type('extension_cord')

    respond_to do |format|
      format.html
    end
  end
  
  def show
    @equipment_registration = EquipmentRegistration.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  # GET /equipment_registrations/new
  def new
    @equipment_registration = EquipmentRegistration.new
    @equipment_registration.user = current_user
    @districts = District.find(:all, :order => "name")

    # find our equipment page
    @page = Page.find_by_label('Equipment Registration Text')

    if !params['admin']
      laptop = Equipment.new(:equipment_type => 'laptop', :first => true)
      interface_box = Equipment.new(:equipment_type => 'interface_box', :first => true)
      pads = Equipment.new(:equipment_type => 'pads', :first => true)
      @equipment_registration.equipment << laptop
      @equipment_registration.equipment << interface_box
      @equipment_registration.equipment << pads
    end

    respond_to do |format|
      format.html {
        render "equipment_registrations/admin/new" if params['admin']
      }
    end
  end

  # POST /equipment_registrations
  def create
    @equipment_registration = EquipmentRegistration.new
    @equipment_registration.attributes = params[:equipment_registration]
    if (params[:equipment_registration][:user_id].nil?)
      @user = @equipment_registration.user = current_user
    else
      @user = @equipment_registration.user
    end
    @equipment_registration.creator = current_user

    validation = true
    if params[:admin]
      # don't perform validation
      validation = false
    end

    respond_to do |format|
      if @equipment_registration.save(validation)
        if params[:admin]
          flash[:notice] = 'Equipment added successfully.'
          format.html { redirect_to(new_equipment_registration_url({:admin => 'true'})) }
        else
          # deliver new official registration notification
          EquipmentRegistrationMailer.deliver_new_registration(@equipment_registration, (admin_emails + equipment_admin_emails).uniq, current_user)
          EquipmentRegistrationMailer.deliver_new_confirmation(@equipment_registration, current_user)
          flash[:notice] = 'Your equipment has been successfully registered. Thanks for letting us borrow it!'
          format.html { redirect_to(root_url) }
        end
      else
        @districts = District.find(:all, :order => "name")
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @equipment_registration = EquipmentRegistration.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
  
  def update
    @equipment_registration = EquipmentRegistration.find(params[:id])

    # make a backup copy of all registration information before changing it
    # this is used to show changes to the information on the updated registration email
    @equipment_registration.backup

    # setup update value
    @update = true

    @equipment_registration.attributes = params[:equipment_registration]

    respond_to do |format|
      if @equipment_registration.save
        EquipmentRegistrationMailer.deliver_update_registration(@equipment_registration, (admin_emails + equipment_admin_emails).uniq, current_user)
        EquipmentRegistrationMailer.deliver_update_confirmation(@equipment_registration, current_user)
        format.js
      else
        format.js { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @equipment_registration = EquipmentRegistration.find(params[:id])
    # deliver canceled registration notification
    EquipmentRegistrationMailer.deliver_cancel_registration(@equipment_registration, (admin_emails + equipment_admin_emails).uniq, current_user)
    EquipmentRegistrationMailer.deliver_cancel_confirmation(@equipment_registration, current_user)
    @equipment_registration.destroy

    respond_to do |format|
      format.js
    end
  end
end
