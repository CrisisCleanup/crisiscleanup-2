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
 * @param {boolean=true} [params.form_map] - Whether or not it's a form map
 */
CCMap.Map = function(params) {
  var $infobox = $('#map-infobox');

  var allSites = [];
  var activeMarkers = [];

  this.canvas = document.getElementById(params.elm);
  this.event_id = params.event_id;
  this.public_map = typeof params.public_map !== 'undefined' ? params.public_map : true;
  this.form_map = typeof params.form_map !== 'undefined' ? params.form_map : true;
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
  this.markerCluster;
  this.markerBounds = new google.maps.LatLngBounds();

  this.map.addListener('click', function() {
    $('#filters-anchor').click();
    $infobox.hide();
  }.bind(this));

  // Setting this up this way just in case we end up with dynamic filters per incident.
  // Eventually, it could require a filters[] param, for example.
  // This could also end up in the setEventId method.
  var filters = new CCMap.Filters({
    onUpdate: populateMap.bind(this)
  });

  this.setEventId = function(event_id) {
    this.event_id = event_id;
    // TODO: refactor this nonsense.
    if (!this.form_map) {
      $infobox.empty();
      buildMarkers.call(this);
    }
    setupAddressAutocomplete.call(this);
  }

  function buildMarkers() {
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
              ccmap: this,
              position: lat_lng,
              site: obj
            });
            allSites.push(site);
            activeMarkers.push(site);
          }, this);
          var mcOptions = {
            maxZoom: 15
          }
          this.markerCluster = new MarkerClusterer(this.map, activeMarkers.map(function(site) { return site.marker; }), mcOptions);
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
    for (var i = 0; i < activeMarkers.length; i++) {
      activeMarkers[i].marker.setMap(this.map);
    }
    activeMarkers = [];
    if (typeof this.markerCluster !== 'undefined'){
      this.markerCluster.clearMarkers();
    }
  }

  function populateMap() {
    clearOverlays.call(this);
    activeMarkers = filters.getFilteredSites(allSites);
    var mcOptions = {
      maxZoom: 15
    }
    this.markerCluster = new MarkerClusterer(this.map, activeMarkers.map(function(site) { return site.marker; }), mcOptions);
  }

  // Address autocomplete
  function setupAddressAutocomplete() {
    var addressField = document.getElementById("legacy_legacy_site_address");
    if (!addressField) { return; }
    var options = {};
    var addressAC = new google.maps.places.Autocomplete(addressField, options);
    var map = this.map;

    addressAC.bindTo('bounds', map);

    google.maps.event.addListener(addressAC, 'place_changed', function() {
      var place = this.getPlace();

      // populate the form with the returned place info
      for (var i = 0; i < place.address_components.length; i++) {
        var addressType = place.address_components[i].types[0];
        switch (addressType) {
          case 'street_number':
            addressField.value = place.address_components[i].long_name;
            break;
          case 'route':
            addressField.value += " " + place.address_components[i].long_name;
            break;
          case 'locality':
            var city = document.getElementById("legacy_legacy_site_city")
            if (city) {
              city.value = place.address_components[i].long_name;
            }
            break;
          case 'administrative_area_level_2':
            var county = document.getElementById("legacy_legacy_site_county")
            if (county) {
              county.value = place.address_components[i].long_name;
            }
            break;
          case 'administrative_area_level_1':
            var state = document.getElementById("legacy_legacy_site_state")
            if (state) {
              state.value = place.address_components[i].long_name;
            }
            break;
          case 'country':
            var country = document.getElementById("legacy_legacy_site_country")
            if (country) {
              country.value = place.address_components[i].long_name;
            }
            break;
          case 'postal_code':
            var zip = document.getElementById("legacy_legacy_site_zip_code")
            if (zip) {
             zip.value = place.address_components[i].long_name;
            }
            break;
          case 'postal_code_suffix':
            var zip = document.getElementById("legacy_legacy_site_zip_code")
            if (zip) {
              zip.value += "-" + place.address_components[i].long_name;
            }
            break;
        }
      }

      if (!place.geometry) {
        return;
      }

      setLatLng(place.geometry.location);

      if (place.geometry.viewport) {
        map.fitBounds(place.geometry.viewport);
      } else {
        map.setCenter(place.geometry.location);
        map.setZoom(17);
      }

      // Set the position of the marker using the place ID and location.
      var marker = new google.maps.Marker({
        draggable: true,
        position: place.geometry.location,
        map: map
      });

      marker.addListener('drag', function() {
        setLatLng(this.position);
      });

    });

    // Takes a google marker position object. Seems to be called location sometimes as well.
    // Whatever. It's the marker attribute that has lat and lng methods on it.
    function setLatLng(position) {
      var latInput = document.getElementById('legacy_legacy_site_latitude');
      var lngInput = document.getElementById('legacy_legacy_site_longitude');
      if (latInput && lngInput) {
        latInput.value = position.lat();
        lngInput.value = position.lng();
      }

    }
  }
}
