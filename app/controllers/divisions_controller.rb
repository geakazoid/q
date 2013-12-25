class DivisionsController < ApplicationController
  require_role 'admin'

  # GET /divisions
  def index
    @divisions = Division.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /divisions/new
  def new
    @division = Division.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /divisions
  def create
    lines = params[:division_info].split(/\r\n/)
    lines.each do |line|
      # split fields and remove leading and trailing whitespace
      details = line.split(/,/)
      2.times do |i|
        details[i].strip! unless details[i].blank?
      end

      # either find the division or create it
      division = Division.find_or_create_by_name(details[0])
      division.price = details[1]
      division.save
    end

    respond_to do |format|
      if !lines.empty?
        flash[:notice] = 'Division(s) added successfully.'
        format.html { redirect_to(divisions_path) }
      else
        flash[:error] = 'You did not enter any division information.'
        format.html { render :action => 'new' }
      end
    end
  end

  # GET /divisions/1/edit
  def edit
    @division = Division.find(params[:id])

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # PUT /divisions/1
  def update
    @division = Division.find(params[:id])
    @division.price = params[:division][:price]
    @division.name = params[:division][:name]

    respond_to do |format|
      if @division.save
        flash[:notice] = 'Division was successfully updated.'
        format.html { redirect_to(divisions_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /divisions/1
  def destroy
    @division = Division.find(params[:id])
    @division.destroy
    
    flash[:notice] = 'Division deleted successfully.'

    respond_to do |format|
      format.html { redirect_to(divisions_url) }
    end
  end
end
