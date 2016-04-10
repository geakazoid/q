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
    @pages = Page.all :order => "label asc"
    extra = ''
    @pages.each do |page|
      if (page.link.blank?)
        link = link_to(page.label, page)
      else
        link = link_to(page.label, page.link)
      end

      if (page.published? and page.show_on_menu?)
        extra += '<li>' + link + '</li>'
      end
    end
    extra
  end

  def pagination(collection)
    if collection.page_count > 1
      "<p class='pages'>" + 'Pages' + ": <strong>" + 
      will_paginate(collection, :inner_window => 10, :next_label => "next", :prev_label => "previous") +
      "</strong></p>"
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
    team_possible = current_user.num_total_teams_possible
    team_available = current_user.num_total_teams_available
    
    equipment_total = current_user.equipment_registrations.size

    info = "My Registrations"
    info << "<p>"

    if team_total > 0
      info << "Team Registrations<br/>"
      if team_complete > 0
        info << "#{team_complete} complete.<br/>"
      end
      if team_incomplete > 0
        info << "#{team_incomplete} incomplete.<br/>"
      end
      info << link_to("View my team registrations.", user_team_registrations_path(current_user))
      info << "<br/><br/>"
    end

    if team_possible > 0
      info << "You have " + team_available.to_s + " of " + team_possible.to_s + " teams you can <a href='/team_registrations/new'>register</a>.<br/><br/>"
    end
    
    if equipment_total > 0
      info << "Equipment Registrations<br/>"
      info << "#{equipment_total} complete.<br/>"
      info << link_to("View my equipment registrations.", user_equipment_registrations_path(current_user))
      info << "<br/><br/>"
    end
    
    if team_total == 0 and equipment_total == 0
      info << "You do not have any active registrations."
    end

    info << "<p>"
  end
  
  def test_output(output)
    "<div class='test_output'>" +
      "<p><b>Test Mode</b></p>" +
        output +
    "</div>"
  end
end
