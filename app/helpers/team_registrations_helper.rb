module TeamRegistrationsHelper
  # display add team link
  def add_team_link(form_builder)
    link_to_function 'add another team' do |page|
      form_builder.fields_for :teams, Team.new, :child_index => 'NEW_RECORD' do |f|
        html = render(:partial => 'team', :locals => { :form => f })
        page << "$('#teams').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()));"
      end
    end
  end
  
  # display remove team link
  def remove_team_link(form_builder)
    if form_builder.object.new_record?
      # If the team is a new record, we can just remove the div from the dom
      link_to_function("Remove", "$(this).closest('.team').remove(); check_for_code_requirement(); update_fee()");
    else
      # However if it's a "real" record it has to be deleted from the database,
      # for this reason the new fields_for, accept_nested_attributes helpers give us _delete,
      # a virtual attribute that tells rails to delete the child record.
      form_builder.hidden_field(:_destroy) +
      link_to_function("Remove", "$(this).closest('.team').hide(); $(this).prev().val('1'); update_fee()")
    end
  end
end