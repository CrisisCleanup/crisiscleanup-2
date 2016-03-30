$(document).ready(function() {
  // TODO: refactor the map.
  var path = $(location).attr('pathname');
  var pathArray = path.split('/');
  var dashboard = pathArray[1] === 'admin';
  var page = pathArray[2];
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
    var ccmap = new CCMap.Map({
      elm: 'worker-map-canvas',
      event_id: id,
      site_id: parseInt($('#site-id').html()),
      public_map: false,
      form_map: pathArray.indexOf('form') !== -1
    });
    // TODO: remove this once the worker map instantiation is setting the event correctly.
    ccmap.setEventId(id);
  }
});
