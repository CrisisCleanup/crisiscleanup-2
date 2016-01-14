var CC = CC || {};
CC.Map = CC.Map || {};

// build map with all of the pins clustered
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
 * @param {number=4} [params.zoom] - The initial zoom level of the map
 * @param {number=39} [params.lat] - Latitude of the initial map center
 * @param {number=-90} [params.lng] - Longitutde of the initial map center
 * @param {boolean=true} [params.public_map] - Whether or not it's a public map
 */
CC.Map.Map = function(params) {
  this.canvas = document.getElementById(params.elm);
  this.event_id = params.event_id;
  this.public_map = typeof params.public_map !== 'undefined' ? params.public_map : true;
  this.zoom = typeof params.zoom !== 'undefined' ? params.zoom : 4;
  this.latitude = typeof params.lat !== 'undefined' ? params.lat : 39;
  this.longitude = typeof params.lng !== 'undefined' ? params.lng : -90;
  this.options = {
    center: new google.maps.LatLng(this.latitude, this.longitude),
    zoom: this.zoom,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    scrollwheel: false
  }
  this.map = new google.maps.Map(this.canvas, this.options)
  this.markers = [];
  this.markerCluster;
  this.markerBounds = new google.maps.LatLngBounds();

  this.setEventId = function(event_id) {
    this.event_id = event_id;
    buildMarkers.call(this);
  }

  var buildMarkers = function() {
    // TODO: remove this self stuff once done troubleshooting.
    var self = this;
    $('.map-wrapper').append('<div class="loading"></div>')

    if (self.public_map) {
      route = "/api/public/map?legacy_event_id=" + self.event_id;
      lat = "blurred_latitude";
      lng = "blurred_longitude";
    } else {
      route = "/api/map?legacy_event_id=" + self.event_id;
      lat = "latitude";
      lng = "longitude";
    }

    $.ajax({
      type: "GET",
      url: route,
      success: function(data) {
        clearOverlays.call(self);
        if (data.length > 0) {
          $.each(data, function(index, obj) {
            self.markerBounds.extend(new google.maps.LatLng(parseFloat(obj[lat]), parseFloat(obj[lng])));
            var marker = new google.maps.Marker({
              position: new google.maps.LatLng(parseFloat(obj[lat]), parseFloat(obj[lng])),
              map: self.map,
              icon: generateIconFilename(obj)
            });
            marker.addListener("click", toggleInfobox.bind(self, obj));
            self.markers.push(marker);
          });
          self.markerCluster = new MarkerClusterer(self.map, self.markers);
          //self.map.fitBounds(self.markerBounds);
        } else {
          // TODO: modal or something other than an alert box.
          console.log("no reported incidents");
        }
        $('.loading').remove();
      },
      error: function() {
        alert('500 error');
      }
    });
  }

  var clearOverlays = function() {
    for (var i = 0; i < this.markers.length; i++) {
      this.markers[i].setMap(this.map);
    }
    this.markers = [];
    if (typeof this.markerCluster !== 'undefined'){
      this.markerCluster.clearMarkers();
    }
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

// TODO: break out the marker methods into a class or extend the google.maps.Marker class
var toggleInfobox = function(obj) {
  console.log(obj, objToHtml(obj));

  var $infobox = $('#map-infobox');
  $infobox.html('<strong>This sucks!</strong>');
}

// TODO: again, this should be in a legacy_site object class of some sort.
/**
 * Takes a legacy_site obj and returns an html table (string) of the attributes
 */
var objToHtml = function(obj) {
  var table = document.createElement('table');
  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
    }
  }
}
