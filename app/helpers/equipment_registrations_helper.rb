module EquipmentRegistrationsHelper
  # display admin menu
  def equipment_admin_menu(equipment_registration)
    content = "<div class='menu' id='menu_" + equipment_registration.id.to_s + "'>"
    content += "<span id='spinner_" + equipment_registration.id.to_s + "' style='display:none;'><img style='vertical-align: middle;' src='/images/spinner_grey.gif'/></span>&nbsp;&nbsp;"
    if admin?
      content += "<span id='menu_text_" + equipment_registration.id.to_s + "'>"
      content += link_to_remote 'Modify',
                                :url => edit_equipment_registration_path(equipment_registration),
                                :method => :get,
                                :loading => "$('#spinner_" + equipment_registration.id.to_s + "').show(); $('#menu_text_" + equipment_registration.id.to_s + "').innerHTML = 'Loading...';"
      content += "&nbsp;::&nbsp;"
      content += link_to_remote 'Delete',
                                :url => equipment_registration,
                                :method => :delete,
                                :confirm => 'Are you sure you want to delete this equipment registration?',
                                :loading => "$('#spinner_" + equipment_registration.id.to_s + "').show(); $('#menu_text_" + equipment_registration.id.to_s + "').innerHTML = 'Deleting...';"
      content += '</span>'
    end
    content += "</div>"
  end

  # display add link
  def add_link(form_builder,equipment_type,equipment_label)
    link_to_function equipment_label do |page|
      form_builder.fields_for :equipment, Equipment.new, :child_index => 'NEW_RECORD' do |f|
        html = render(:partial => equipment_type, :locals => { :form => f })
        page << "$('#equipment_list').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()));"
      end
    end
  end

  # display add full set link
  def add_full_set_link(form_builder)
    link_to_function 'Extra Full Set' do |page|
      form_builder.fields_for :equipment, Equipment.new, :child_index => 'NEW_RECORD' do |f|
        html = render(:partial => 'laptop', :locals => { :form => f })
        page << "$('#equipment_list').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()));"
      end
      form_builder.fields_for :equipment, Equipment.new, :child_index => 'NEW_RECORD' do |f|
        html = render(:partial => 'interface_box', :locals => { :form => f })
        page << "$('#equipment_list').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()));"
      end
      form_builder.fields_for :equipment, Equipment.new, :child_index => 'NEW_RECORD' do |f|
        html = render(:partial => 'pads', :locals => { :form => f })
        page << "$('#equipment_list').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()));"
      end
    end
  end

  # display removal link
  def remove_link(form_builder)
    if form_builder.object.new_record?
      # If the equipment is a new record, we can just remove the div from the dom
      link_to_function("Remove", "$(this).closest('.equipment').remove();");
    else
      # However if it's a "real" record it has to be deleted from the database,
      # for this reason the new fields_for, accept_nested_attributes helpers give us _delete,
      # a virtual attribute that tells rails to delete the child record.
      form_builder.hidden_field(:_destroy) +
      link_to_function("Remove", "$(this).closest('.equipment').hide(); $(this).prev().val('1')")
    end
  end
end