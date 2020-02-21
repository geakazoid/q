module ApplicationHelper
  
  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end
  
  # outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end
  
  # method to use tinymce for wysiwyg editing
  def use_tinymce
    @content_for_tinymce = "" 
    content_for :tinymce do
      javascript_include_tag "tiny_mce/tiny_mce"
    end
    @content_for_tinymce_init = "" 
    content_for :tinymce_init do
      javascript_include_tag "mce_editor"
    end
  end

  # method to generate page links for the header
  def extra_pages
    @pages = Page.all :conditions => "event_id = " + Event.active_event.id.to_s + " and parent_id is null", :order => "label asc"
    extra = ''
    @pages.each do |page|
      unless !page.published? or !page.show_on_menu?
        if page.menu?
          link = '<li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">' + page.label + ' <span class="caret"></span></a><ul class="dropdown-menu">'
          @sub_pages = Page.all :conditions => "event_id = " + Event.active_event.id.to_s + " and parent_id = " + page.id.to_s, :order => "label asc"
          @sub_pages.each do |sub_page|
            if sub_page.link.blank?
              sublink = link_to(sub_page.label, sub_page)
            else
              sublink = link_to(sub_page.label, sub_page.link)
            end
            link += '<li>' + sublink + '</li>'
          end
          link += "</ul>"
          extra += link
        else
          if page.link.blank?
            link = link_to(page.label, page)
          else
            link = link_to(page.label, page.link)
          end

          if (page.published? and page.show_on_menu?)
            extra += '<li>' + link + '</li>'
          end
        end
      end
    end
    extra
  end

  def pagination(collection)
    if collection.page_count > 1
      "<strong>" + 
      will_paginate(collection, :inner_window => 10, :next_label => "&nbsp;>", :prev_label => "<&nbsp;") +
      "</strong>"
    end
  end
  
  def next_page(collection)
    unless collection.current_page == collection.page_count or collection.page_count == 0
      "<p style='float:right;'>" + link_to("Next page", { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
    end
  end

  def registration_information
    team_complete = current_user.complete_team_registrations.size
    team_incomplete = current_user.incomplete_team_registrations.size
    team_total = current_user.team_registrations.size

    participant_complete = current_user.complete_participant_registrations.size
    participant_incomplete = current_user.incomplete_participant_registrations.size
    participant_total = current_user.participant_registrations.size
    
    equipment_total = current_user.equipment_registrations.size

    info = "<h4>My Registrations</h4>"
    info << "<p>"

    if team_total > 0
      info << "Team Registrations<br/>"
      info << "#{team_complete} complete.<br/>"
      info << link_to("View my team registrations.", user_team_registrations_path(current_user))
      info << "<br/><br/>"
    end

    if participant_total > 0
      info << "Participant Registrations<br/>"
      info << "#{participant_complete} complete.<br/>"
      info << link_to("View my participant registrations.", user_participant_registrations_path(current_user))
      info << "<br/><br/>"
    end
    
    if equipment_total > 0
      info << "Equipment Registrations<br/>"
      info << "#{equipment_total} complete.<br/>"
      info << link_to("View my equipment registrations.", user_equipment_registrations_path(current_user))
      info << "<br/><br/>"
    end
    
    if team_total == 0 and participant_total == 0 and equipment_total == 0
      info << "You do not have any registrations."
    end
    info << "</p>"
    info << "<div class='alert alert-danger' style='margin-bottom:10px;'><strong>Note!</strong> Paid registrations may take several minutes to appear on quizzingevents.com.</div>"
  end
  
  def test_output(output)
    "<div class='test_output'>" +
      "<p><b>Test Mode</b></p>" +
        output +
    "</div>"
  end
end
