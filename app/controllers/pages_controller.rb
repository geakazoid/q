class PagesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :tinymce_upload

  # GET /pages
  def index
    @selected_event = params[:event_id] ? params[:event_id] : Event.active_event.id
    @pages = Page.find(:all, :conditions => "event_id = #{@selected_event}" )
    @events = Event.get_events

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /pages/:id
  def show
    @page = Page.find(params[:id])
    record_not_found if @page.nil?
    
    if (!@page.published? and !admin?)
      record_not_found
    else
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  end

  # GET /pages/new
  def new
    @page = Page.new
    @events = Event.get_events
    @page.event_id = Event.active_event.id
    @pages = Page.find(:all, :conditions => "menu = true" )

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /pages/:id/edit
  def edit
    @page = Page.find(params[:id])
    @pages = Page.find(:all, :conditions => "menu = true" )
  end

  # POST /pages
  def create
    @page = Page.new(params[:page])
    @events = Event.get_events

    respond_to do |format|
      if @page.save
        if @page.menu?
          flash[:notice] = 'Top Level Menu was successfully created.'
          format.html { redirect_to(pages_path) }
        else
          flash[:notice] = 'Page was successfully created.'
          format.html { redirect_to(@page) }
        end
      else
        format.html { render :action => 'new' }
      end
    end
  end

  # PUT /pages/:id
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@page) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  # DELETE /pages/:id
  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    flash[:notice] = 'Page was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to(pages_path) }
    end
  end
  
  # GET /
  def home
    @page = Page.find_by_label('Home')
    @page = Page.new if @page.nil?
    
    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

  def tinymce_upload
    name = params[:image].original_filename
    extension = File.extname(name)
    directory = "public/files"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:image].read) }
    images = [".png",".jpg",".gif",".jpeg",".bmp"]
    if (images.include?(extension.downcase))
      @insertString = "<img src=\"/files/"+name+"\" />"
    else
      @insertString = "<a href=\"/files/"+name+"\">"+name+"</a>"
    end
    render :layout => false
  end

  def video
    @rooms = {'chap113' => 'Chapel 113',
      'chap124' => 'Chapel 124',
      'leftside' => 'Stage Left-Side',
      'leftfront' => 'Stage Left-Front',
      'rear' => 'Stage Rear',
      'center' => 'Stage Center',
      'front' => 'Stage Front',
      'rightfront' => 'Stage Right-Front',
      'rightside' => 'Stage Right-Side',
      'balcony' => 'Balcony'
    }
  end

  def auditorium
    render :layout => "empty"
  end
end