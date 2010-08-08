$(document).ready(function() {
  $("button, input:submit").button();
  $('#ajax-indicator').aqFloater({attach: 'n'});
  $("#ajax-indicator").bind("ajaxSend", function(){
     $(this).show();
   }).bind("ajaxComplete", function(){
     $(this).hide();
   });

});

