// build map with all of the pins clustered
var markers = [];
var map;
var markerCluster;
var markerBounds = new google.maps.LatLngBounds();
var iconDir = '/assets/map_icons/';
var unclaimedStatusColorMap = {
  "Open, unassigned": "orange",
  "Open, assigned": "yellow",
  "Open, partially completed": "yellow",
  "Open, partially completed": "yellow",
  "Closed, completed": "green",
  "Closed, incomplete": "gray",
  "Closed, out of scope": "gray",
  "Closed, done by others": "gray",
  "Closed, no help wanted": "xgray",
  "Closed, rejected": "xgray",
  "Closed, duplicate": "xgray"
};

/**
 * Initializes a Google map object
 * @constructor
 * @param {Object} params - The configuration paramters
 * @param {string} params.elm - The id of the map div
 * @param {number} params.event_id - The id of the event
 * @param {number} [params.zoom] - The initial zoom level of the map
 * @param {number} [params.lat] - Latitude of the initial map center
 * @param {number} [params.lng] - Longitutde of the initial map center
 */
function CCMAP(params) {
  this.canvas = document.getElementById(params.elm);
  this.worker =  params.elm !== 'public-map-canvas' ? true : false;
  this.incident = params.event_id;
  this.zoom = typeof params.zoom !== 'undefined' ? params.zoom : 4;
  this.latitude = typeof params.lat !== 'undefined' ? params.lat : 39;
  this.longitude = typeof params.lng !== 'undefined' ? params.lng : -90;
  this.options = {
    center: new google.maps.LatLng(this.latitude, this.longitude),
    zoom: this.zoom,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    scrollwheel: false
  }
  map = new google.maps.Map(this.canvas, this.options)
}

/**
 * Fetch the sites for the incident
 * @param {number} id - The event id
 */
CCMAP.prototype.buildMarkers = function(id) {
  $('.map-wrapper').append('<div class="loading"></div>')
  this.incident = id;
  route = this.worker ? "/api/map?legacy_event_id="+id : "/api/public/map?legacy_event_id="+id
  lat = this.worker ? "latitude" : "blurred_latitude";
  lng = this.worker ? "longitude" : "blurred_longitude";
  $.ajax({
    type: "GET",
    url: route,
    success: function(data) {
      clearOverlays();
      if (data.length > 0) {
        $.each(data, function(index, obj) {
          markerBounds.extend(new google.maps.LatLng(parseFloat(obj[lat]), parseFloat(obj[lng])));
          var marker = new google.maps.Marker({
            position: new google.maps.LatLng(parseFloat(obj[lat]), parseFloat(obj[lng])),
            map: map,
            icon: generateIconFilename(obj)
          });
          markers.push(marker);
        })
        markerCluster = new MarkerClusterer(map, markers);
        map.fitBounds(markerBounds);
        $('.loading').remove();
      } else {
        alert("no reported incidents");
      }
    },
    error: function() {
      alert('500 error');
    }
  });
}

var clearOverlays = function() {
  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(map);
  }
  markers = [];
  if (typeof markerCluster !== 'undefined'){
    markerCluster.clearMarkers();
  }
}

// TODO: check if the file exists on the server or some other validation here.
var generateIconFilename = function(obj) {
  var color;
  if (obj.claimed_by) {
    color = unclaimedStatusColorMap[obj.status];
  } else {
    color = "red";
  }
  return iconDir + obj.work_type + '_' + color + '.png';
}
