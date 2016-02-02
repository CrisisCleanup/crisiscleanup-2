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
  var $infobox = $('#map-infobox');

  var userOrg = '[organization name]';
  var filters = [
    { id: "claimed-by", label: "Claimed by " + userOrg },
    { id: "unclaimed", label:  "Unclaimed" },
    { id: "open",  label: "Open" },
    { id: "closed", label: "Closed" },
    { id: "reported-by", label: "Reported by " + userOrg },
    { id: "flood-damage", label: "Primary problem is flood damage" },
    { id: "trees", label: "Primary problem is trees" },
    { id: "debris", label: "Debris removal" },
    { id: "goods-and-services", label: "Primary need is goods and services" }
  ];

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

  this.map.addListener('click', function() {
    $('#map-infobox').hide();
  }.bind(this));

  this.setEventId = function(event_id) {
    this.event_id = event_id;
    buildMarkers.call(this);
  }

  // The filter checkboxes in the sidebar
  buildFilters();

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
              position: lat_lng,
              site: obj
            });
            this.sites.push(site);
          }, this);
          var mcOptions = {
            maxZoom: 15
          }
          this.markerCluster = new MarkerClusterer(this.map, this.sites.map(function(site) { return site.marker; }), mcOptions);
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

  function buildFilters() {
    var filterList = document.getElementById('map-filters');
    filters.forEach(function(filter) {
      var input = document.createElement('input');
      input.setAttribute('id', filter.id);
      input.setAttribute('type', 'checkbox');
      var label = document.createElement('label');
      label.setAttribute('for', filter.id);
      label.appendChild(document.createTextNode(filter.label));
      var listItem = document.createElement('li');
      listItem.setAttribute('data-filter', filter.id);
      listItem.appendChild(input);
      listItem.appendChild(label);
      listItem.addEventListener('click', filterSites, true);
      filterList.appendChild(listItem);
    }, this);
    //<li><input id="claimed-by-filter" type="checkbox"><label for="claimed-by-filter">Claimed by <%= current_user.legacy_organization.name %></label></li>
    //<li><input id="unclaimed-filter" type="checkbox"><label for="unclaimed-filter">Unclaimed</label></li>
    //<li><input id="open-filter" type="checkbox"><label for="open-filter">Open</label></li>
    //<li><input id="closed-filter" type="checkbox"><label for="closed-filter">Closed</label></li>
    //<li><input id="reported-by-filter" type="checkbox"><label for="reported-by-filter">Reported by <%= current_user.legacy_organization.name %></label></li>
    //<li><input id="flood-damage-filter" type="checkbox"><label for="flood-damage-filter">Primary problem is flood damage</label></li>
    //<li><input id="trees-filter" type="checkbox"><label for="trees-filter">Primary problem is trees</label></li>
    //<li><input id="goods-and-services-filter" type="checkbox"><label for="goods-and-services-filter">Primary need is goods and services</label></li>
  }

  function filterSites(event) {
    //console.log(event.target, this);
  }
}
