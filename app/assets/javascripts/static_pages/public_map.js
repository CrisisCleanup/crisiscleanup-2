$(function() {
  var markersArray = [];

  function clearOverlays() {
    if (markersArray) {
      for (i in markersArray) {
        markersArray[i].setMap(null);
      }
    }
  }


  var map;
  function initialize() {
    var mapCanvas = document.getElementById('map-canvas');
    var mapOptions = {
      center: new google.maps.LatLng(39, -90),
      zoom: 4,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      scrollwheel: false    
    }
    map = new google.maps.Map(mapCanvas, mapOptions)
  }

  
  google.maps.event.addDomListener(window, 'load', initialize);

  $( ".select_incident" ).change(function() {
    var event_id = $(".select_incident").val();
    var publicPinsApi = "/api/public/map?legacy_event_id=" + event_id;

    console.log(publicPinsApi);
    clearOverlays();
    $.get( publicPinsApi, function( data ) {
      $.each(data, function(index, obj) {
        var marker1 = new google.maps.Marker({
          position: new google.maps.LatLng(parseFloat(obj["blurred_latitude"]), parseFloat(obj["blurred_longitude"])),
            map: map
        });
        markersArray.push(marker1);
      })
    });
  });
});
