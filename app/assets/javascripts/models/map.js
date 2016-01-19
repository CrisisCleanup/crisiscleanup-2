var CCMap = CCMap || {};

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
CCMap.Map = function(params) {
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
  this.sites = [];
  this.markerCluster;
  this.markerBounds = new google.maps.LatLngBounds();

  this.setEventId = function(event_id) {
    this.event_id = event_id;
    buildMarkers.call(this);
  }

  function buildMarkers() {
    // TODO: fix this. I'd like to not directly access a parent DOM element if I can help it.
    $('.map-wrapper').append('<div class="loading"></div>');

    if (this.public_map) {
      route = "/api/public/map?legacy_event_id=" + this.event_id;
      lat = "blurred_latitude";
      lng = "blurred_longitude";
    } else {
      route = "/api/map?legacy_event_id=" + this.event_id;
      lat = "latitude";
      lng = "longitude";
    }

    $.ajax({
      type: "GET",
      context: this,
      url: route,
      success: function(data) {
        clearOverlays.call(this);
        if (data.length > 0) {
          data.forEach(function(obj, index) {
            var lat_lng = new google.maps.LatLng(parseFloat(obj[lat]), parseFloat(obj[lng]));
            this.markerBounds.extend(lat_lng);
            var site = new CCMap.Site({
              map: this.map,
              position: lat_lng,
              site: obj
            });
            this.sites.push(site);
          }, this);
          this.markerCluster = new MarkerClusterer(this.map, this.sites.map(function(site) { return site.marker; }));
          this.map.fitBounds(this.markerBounds);
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

  function clearOverlays() {
    for (var i = 0; i < this.sites.length; i++) {
      this.sites[i].marker.setMap(this.map);
    }
    this.sites = [];
    if (typeof this.markerCluster !== 'undefined'){
      this.markerCluster.clearMarkers();
    }
  }
}
