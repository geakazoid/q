module OfficialsHelper
  # display admin menu
  def admin_menu(official)
    content = "<div class='menu' id='menu_" + official.id.to_s + "'>"
    content += "<span id='spinner_" + official.id.to_s + "' style='display:none;'><img style='vertical-align: middle;' src='/images/spinner_grey.gif'/></span>&nbsp;&nbsp;"
    if admin? or official_admin?
      content += "<span id='menu_text_" + official.id.to_s + "'>"
      content += "<a href=\"#\" id=\"evaluations_link_" + official.id.to_s + "\" onClick=\"$( '#evaluations_" + official.id.to_s + "' ).toggle( 'fade', 1000 ); return false;\">Evaluations</a>"
      content += '</span>'
    end
    content += "</div>"
  end
end