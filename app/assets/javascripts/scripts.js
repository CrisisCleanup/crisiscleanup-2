$(document).ready(function() {
  // TODO: refactor the map.
  var path = $(location).attr('pathname');
  var pathArray = path.split('/');
  var dashboard = pathArray[1] === 'admin';
  var page = pathArray[2];
  var elem = '.'+page;
  var worker_map = $('#worker-map-canvas').length
  var event_id;

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
    event_id = typeof $('.m-id.hidden')[0] !== 'undefined' ? $('.m-id.hidden')[0].innerHTML : 'none';
    var ccmap = new CCMap.Map({
      elm: 'worker-map-canvas',
      event_id: event_id,
      site_id: parseInt($('#site-id').html()),
      public_map: false,
      form_map: pathArray.indexOf('form') !== -1
    });
    // TODO: remove this once the worker map instantiation is setting the event correctly.
    ccmap.setEventId(event_id);
  }

  // Setup the download-csv-button if it's present
  var $dlbtn = $('#download-csv-btn');
  if ($dlbtn) {
    var enabled = true;
    $dlbtn.click(function(e) {
      e.preventDefault();
      if (enabled) {
        enabled = false;
        $dlbtn.html('<i class="fa fa-spinner fa-spin"></i>');
        window.location = "/worker/incident/" + event_id + "/download-sites";

        // debounce of sorts
        setTimeout(function() {
          enabled = true;
          $dlbtn.html('CSV');
        }, 15000);

      }
    });
  }
});
