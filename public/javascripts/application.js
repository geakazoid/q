$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

$(function(){
  $("#event_select").change(function(){
    window.location='?event_id=' + this.value
  });
});