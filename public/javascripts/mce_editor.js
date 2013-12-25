tinyMCE.init({
    theme:"advanced",
    mode:"textareas",
    plugins : "safari,upload",
    //theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,|,bullist,numlist,|,undo,redo,|,link,unlink,cleanup,upload",
    theme_advanced_buttons1_add : "separator,forecolor,backcolor",
    theme_advanced_buttons2_add : "separator,upload",
    theme_advanced_toolbar_location : "top",
    theme_advanced_toolbar_align : "left",
    theme_advanced_resizing : true,
    theme_advanced_resize_horizontal : true,
    relative_urls : false,
    extended_valid_elements : "iframe[src|width|height|name|align]",
    width : "640"
});