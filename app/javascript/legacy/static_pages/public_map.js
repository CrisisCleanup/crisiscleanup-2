import CCMap from '../models'

var GoogleMapsApiLoader = require('google-maps-api-loader');

$(document).ready(function () {
    var public_map = $('#public-map-canvas').length
    if (public_map != 0) {
      var id = typeof $('.m-id.hidden')[0] !== 'undefined' ? $('.m-id.hidden')[0].innerHTML : 'none';
      GoogleMapsApiLoader({
        libraries: ['places'],
        apiKey: process.env.GOOGLE_MAPS_API_KEY
      })
        .then(function (googleApi) {
          var ccmap = new CCMap.Map({
            elm: 'public-map-canvas',
            event_id: id,
            form_map: false,
            google: googleApi
          });

          $(".select_incident").change(function () {
            var event_id = $(".select_incident").val();
            ccmap.setEventId(event_id);
          });
        }, function (err) {
          console.error(err);
        });
    }
  }
);
