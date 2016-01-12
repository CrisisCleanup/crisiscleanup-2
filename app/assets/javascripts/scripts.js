$(document).ready(function() {
  var path = $(location).attr('pathname');
  var dashboard = path.split('/')[1] == 'admin';
  var page = path.split('/')[2];
  var elem = '.'+page;
  var worker_map = $('#worker-map-canvas').length

  if (dashboard){
    $('select').foundationSelect();
    $('.dashboard li').removeClass('active');
    $(elem).addClass('active');
    if ($(elem).parents('.has-dropdown').length) {
      $(elem).parents('.has-dropdown').addClass('active');
    }
  }
  // if a map is on the page get incident id
  if (worker_map !== 0) {
    var id = typeof $('.m-id.hidden')[0] !== 'undefined' ? $('.m-id.hidden')[0].innerHTML : 'none';
    var ccmap = new CCMAP({
      elm: 'worker-map-canvas',
      event_id: id
    });
    ccmap.buildMarkers(id);
  }
});
