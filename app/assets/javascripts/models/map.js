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
  var markerClustererOptions = {
    maxZoom: 15,
    styles: [
      {
        textColor: 'black',
        url: image_path('map_icons/m1.png'),
        height: 53,
        width: 52
      },
      {
        textColor: 'black',
        url: image_path('map_icons/m2.png'),
        height: 56,
        width: 55
      },
      {
        textColor: 'black',
        url: image_path('map_icons/m3.png'),
        height: 66,
        width: 65
      },
      {
        textColor: 'black',
        url: image_path('map_icons/m4.png'),
        height: 78,
        width: 77
      },
      {
        textColor: 'black',
        url: image_path('map_icons/m5.png'),
        height: 90,
        width: 89
      }
    ]
  }

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
  this.markerBounds = new google.maps.LatLngBounds();
  this.markerClusterer = new MarkerClusterer(this.map, [], markerClustererOptions);

  this.map.addListener('click', function() {
    $('#filters-anchor').click();
    $infobox.hide();
    this.showFilters();
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
    if (this.form_map) {
      setupAddressAutocomplete.call(this);
      new CCMap.Form({
        event_id: this.event_id
      });
    } else {
      $infobox.empty();
      buildMarkers.call(this);
    }
  }

  this.showFilters = function() {
    var $filtersView = $('#filters-view');
    var $formView = $('#form-view');

    if ($filtersView.hasClass('hide')) {
      $formView.addClass('hide');
      $filtersView.removeClass('hide');
    }
  }

  this.showForm = function() {
    // Hacky way to hide the form alert box between edits.
    $('#form-view .alert-box a.close').click();

    var $filtersView = $('#filters-view');
    var $formView = $('#form-view');

    if ($formView.hasClass('hide')) {
      $filtersView.addClass('hide');
      $formView.removeClass('hide');
    }
  }

  function zoomToMarker(id) {
    var matchArray = $.grep(allSites, function(site) { return site.site.id === id; });
    if (matchArray.length > 0) {
      var marker = matchArray[0].marker;
      this.map.setZoom(17);
      this.map.setCenter(marker.getPosition());
      marker.setAnimation(google.maps.Animation.BOUNCE);
      // Stop the animation after awhile
      setTimeout(function() {
        marker.setAnimation(null);
      }, 6000);
    } else {
      console.warn('Matching site not found.');
    }
  }
  zoomToMarker = zoomToMarker.bind(this);

  function setupSearch(siteList) {
    window.siteList = siteList;
    var $searchBtn = $('#map-search-btn');
    // Initialize the search typeahead
    // TODO: this shouldn't be loaded or even rendered on every page.
    if ($searchBtn) {
      var siteBh = new Bloodhound({
        datumTokenizer: function(obj) {
          return Bloodhound.tokenizers.whitespace(obj.siteStr);
        },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        identify: function(obj) {
          return obj.id;
        },
        local: siteList.map(function(site) {
          var siteStr = site.site.case_number + ': ';
          siteStr += ' ' + site.site.name;
          siteStr += ' ' + site.site.address;
          siteStr += ' ' + site.site.city;
          siteStr += ' ' + site.site.state;
          siteStr += ' ' + site.site.zip_code;
          return {
            id: site.site.id,
            siteStr: siteStr
          }
        })
      });

      var searchOpts = {
        minLength: 3,
        highlight: true
      };

      var sourceOpts = {
        name: 'sites',
        limit: 5,
        displayKey: 'siteStr',
        source: siteBh.ttAdapter(),
        templates: {
          notFound: [
            '<div class="empty-message">',
            'No sites match your query',
            '</div>'
          ].join('\n')
        }
      };

      $searchBtn.typeahead(searchOpts, sourceOpts);
      $searchBtn.bind('typeahead:select', function(event, selection) {
        zoomToMarker(selection.id);
      });
    }
  }

  function getMarkers(route, page) {
    return $.ajax({
      type: "GET",
      context: this,
      url: route + page,
      success: function(data) {
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
          this.map.fitBounds(this.markerBounds);
          this.markerClusterer.addMarkers(activeMarkers.map(function(site) { return site.marker; }));
        }
      },
      error: function() {
        console.error('500 error in map site request');
      }
    });
  }

  function buildMarkers() {
    // TODO: this isn't visible for some reason
    $('.map-wrapper').append('<div class="loading"></div>');
    var PAGE_SIZE = 250;

    if (this.public_map) {
      route = "/api/public/map/" + this.event_id + "/" + PAGE_SIZE + "/";
      lat = "blurred_latitude";
      lng = "blurred_longitude";
    } else {
      route = "/api/map/" + this.event_id + "/" + PAGE_SIZE + "/";
      lat = "latitude";
      lng = "longitude";
    }

    $.ajax({
      url: '/api/count/' + this.event_id,
      method: 'get',
      context: this,
      success: function(data) {
        clearOverlays.call(this);

        pageLimit = Math.ceil(data / PAGE_SIZE);
        ajaxCalls = [];
        for (var page = 1; page <= pageLimit; page++) {
          ajaxCalls.push(getMarkers.call(this, route, page));
        }

        $.when.apply(this, ajaxCalls).done(function() {
          setupSearch(allSites);
          $('.loading').remove();
        }.bind(this));
      }
    });

  }

  function clearOverlays() {
    for (var i = 0; i < activeMarkers.length; i++) {
      activeMarkers[i].marker.setMap(this.map);
    }
    activeMarkers = [];
    if (typeof this.markerClusterer !== 'undefined') {
      this.markerClusterer.clearMarkers();
    }
  }

  function populateMap() {
    clearOverlays.call(this);
    activeMarkers = filters.getFilteredSites(allSites);
    this.markerClusterer.addMarkers(activeMarkers.map(function(site) { return site.marker; }));
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
