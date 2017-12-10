/**
 * Initializes a Google map object
 * @constructor
 * @param {Object} params - The configuration paramters
 * @param {string} params.elm - The id of the map div
 * @param {number} params.event_id - The id of the event
 * @param {number=0} [params.site_id] - The id of the site for the edit form
 * @param {number=4} [params.zoom] - The initial zoom level of the map
 * @param {number=39} [params.lat] - Latitude of the initial map center
 * @param {number=-90} [params.lng] - Longitutde of the initial map center
 * @param {boolean=true} [params.public_map] - Whether or not it's a public map
 * @param {boolean=true} [params.form_map] - Whether or not it's a form map
 */

import {Filters} from './filter';
import Form from './form';
import Site from './marker';
import Raven from 'raven-js';
import {addLocationButton} from "./util";

export default function(params) {
  let $infobox = $('#map-infobox');

  let allSites = [];
  let activeMarkers = [];
  const markerClustererOptions = {
    maxZoom: 11,
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
  };

  this.canvas = document.getElementById(params.elm);
  this.event_id = params.event_id;
  this.site_id = typeof params.site_id !== 'undefined' ? params.site_id : 0;
  this.public_map = typeof params.public_map !== 'undefined' ? params.public_map : true;
  this.form_map = typeof params.form_map !== 'undefined' ? params.form_map : true;
  this.zoom = typeof params.zoom !== 'undefined' ? params.zoom : 4;
  this.latitude = typeof params.lat !== 'undefined' ? params.lat : 39;
  this.longitude = typeof params.lng !== 'undefined' ? params.lng : -90;
  this.options = {
    center: new params.google.maps.LatLng(this.latitude, this.longitude),
    zoom: this.zoom,
    maxZoom: 18,
    mapTypeId: params.google.maps.MapTypeId.ROADMAP,
    scrollwheel: false
  }
  this.map = new params.google.maps.Map(this.canvas, this.options);
  this.markerBounds = new params.google.maps.LatLngBounds();
  this.markerClusterer = new MarkerClusterer(this.map, [], markerClustererOptions);

  this.map.addListener('click', function() {
    $('#filters-anchor').click();
    $infobox.hide();
    this.showFilters();
  }.bind(this));

  // Setting this up this way just in case we end up with dynamic filters per incident.
  // Eventually, it could require a filters[] param, for example.
  // This could also end up in the setEventId method.
  let filters = new Filters({
    onUpdate: populateMap.bind(this)
  });

  this.setEventId = function(event_id) {
    $('#map-infobox').hide();
    this.event_id = event_id;
    // TODO: refactor this nonsense.
    if (this.form_map) {
      setupAddressAutocomplete.call(this);
      let form = new Form({
        event_id: this.event_id
      });
      form.prep(this.map);
    } else {
      $infobox.empty();
      buildMarkers.call(this);
    }
  };

  this.showFilters = function() {
    let $filtersView = $('#filters-view');
    let $formView = $('#form-view');
    let $historyView = $('#history-view');

    if ($filtersView.hasClass('hide')) {
      $formView.addClass('hide');
      $historyView.addClass('hide');
      $filtersView.removeClass('hide');
    }
  };

  this.showForm = function() {
    // Hacky way to hide the form alert box between edits.
    let $formView = $('#form-view');
    $formView.find('.alert-box a.close').click();

    let $filtersView = $('#filters-view');
    let $historyView = $('#history-view');

    if ($formView.hasClass('hide')) {
      $filtersView.addClass('hide');
      $historyView.addClass('hide');
      $formView.removeClass('hide');
    }
  };

  this.showHistory = function() {
    let $formView = $('#form-view');
    $formView.find('.alert-box a.close').click();

    let $filtersView = $('#filters-view');
    let $historyView = $('#history-view');

    if ($historyView.hasClass('hide')) {
      $filtersView.addClass('hide');
      $formView.addClass('hide');
      $historyView.removeClass('hide');
    }
  };

  function zoomToMarker(id) {
    let matchArray = $.grep(allSites, function(site) { return site.site.id === id; });
    if (matchArray.length > 0) {
      let marker = matchArray[0].marker;
      this.map.setZoom(17);
      this.map.setCenter(marker.getPosition());
      marker.setAnimation(params.google.maps.Animation.BOUNCE);
      // Stop the animation after awhile
      setTimeout(function() {
        marker.setAnimation(null);
      }, 6000);
    } else {
      Raven.captureMessage("Matching site not found.", {level: 'warning'});
    }
  }
  zoomToMarker = zoomToMarker.bind(this);

  function setupSearch(siteList) {
    let $searchBtn = $('#map-search-btn');
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
        if (data != null && data.length > 0) {
          if (route.indexOf('public') >= 0) {
            data.forEach(function(obj, index) {
              var lat_lng = new params.google.maps.LatLng(parseFloat(obj.blurred_latitude), parseFloat(obj.blurred_longitude));
              this.markerBounds.extend(lat_lng);
              var site = new Site({
                map: this.map,
                ccmap: this,
                position: lat_lng,
                site: obj
              });
              allSites.push(site);
              activeMarkers.push(site);
            }, this);

          } else {
            data.forEach(function(obj, index) {
              var lat_lng = new params.google.maps.LatLng(parseFloat(obj.latitude), parseFloat(obj.longitude));
              this.markerBounds.extend(lat_lng);
              var site = new Site({
                map: this.map,
                ccmap: this,
                position: lat_lng,
                site: obj
              });
              allSites.push(site);
              activeMarkers.push(site);
            }, this);

          }

          this.map.fitBounds(this.markerBounds);
          this.markerClusterer.addMarkers(activeMarkers.map(function(site) { return site.marker; }));
        } else {
          Raven.captureMessage("Something is wrong with the map data: " + data.constructor);
        }
      },
      error: function() {
        Raven.captureMessage("500 error in map site request");
      }
    });
  }

  function buildMarkers() {
    $('.map-wrapper').append('<div class="loading"></div>');
    var PAGE_SIZE = 15000;

    let route = "";
    let lat = "";
    let lng = "";
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

        let pageLimit = Math.ceil(data / PAGE_SIZE);
        let ajaxCalls = [];
        for (var page = 1; page <= pageLimit; page++) {
          ajaxCalls.push(getMarkers.call(this, route, page));
        }

        $.when.apply(this, ajaxCalls).done(function() {
          setupSearch(allSites);
          $('.loading').remove();
          if (this.site_id > 0) {
            editSite.call(this);
          }
        }.bind(this));
      }
    });

  }

  // zooms in on the marker of the site
  // to edit and shows the form
  function editSite() {
    zoomToMarker(this.site_id);

    var site = activeMarkers.find(function(obj) {
      return obj.site.id === this.site_id;
    }, this);
    params.google.maps.event.trigger(site.marker, 'click');
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
    var city = document.getElementById("legacy_legacy_site_city");
    var county = document.getElementById("legacy_legacy_site_county");
    var state = document.getElementById("legacy_legacy_site_state");
    var country = document.getElementById("legacy_legacy_site_country");
    var zip = document.getElementById("legacy_legacy_site_zip_code");

    if (!addressField) { return; }
    var options = {};
    var addressAC = new params.google.maps.places.Autocomplete(addressField, options);
    var map = this.map;

    addressAC.bindTo('bounds', map);

    params.google.maps.event.addListener(addressAC, 'place_changed', function() {
      var place = this.getPlace();
      populateAddressFields.call(this, place);
    });

    city.addEventListener('change', geocodeQuery.bind(this));
    state.addEventListener('change', geocodeQuery.bind(this));
    zip.addEventListener('change', geocodeQuery.bind(this));

    function geocodeQuery() {
      var num_values = 0;
      if (city.value !== "") { num_values++ };
      if (state.value !== "") { num_values++ };
      if (zip.value !== "") { num_values++ };

      if (addressField.value !== "" && num_values > 0) {
        var address = addressField.value + ",+" + city.value + ",+" + state.value + "+" + zip.value;
        $.ajax({
          method: 'get',
          url: "https://maps.googleapis.com/maps/api/geocode/json?address=" + address,
          context: this,
          success: function(data) {
            if (data.status === "OK") {
              populateAddressFields.call(this, data.results[0]);
            } else {
              Raven.captureMessage("Something went wrong with the geocoding query.", {level: 'warning'});
            }
          }
        });
      }
    }

    function populateAddressFields(place) {
      var updateZip = false;

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
            if (city && city.value === '') {
              city.value = place.address_components[i].long_name;
            }
            break;
          case 'administrative_area_level_2':
            if (county && county.value === '') {
              county.value = place.address_components[i].long_name;
            }
            break;
          case 'administrative_area_level_1':
            if (state && state.value === '') {
              state.value = place.address_components[i].long_name;
            }
            break;
          case 'country':
            if (country && country.value === '') {
              country.value = place.address_components[i].long_name;
            }
            break;
          case 'postal_code':
            if (zip && zip.value === '') {
              zip.value = place.address_components[i].long_name;
              updateZip = true;
            }
            break;
          case 'postal_code_suffix':
            if (zip && updateZip) {
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
      var marker = new params.google.maps.Marker({
        draggable: true,
        position: place.geometry.location,
        map: map
      });

      marker.addListener('drag', function() {
        setLatLng(this.position);
      });
    }

    // Takes a google marker position object. Seems to be called location sometimes as well.
    // Whatever. It's the marker attribute that has lat and lng methods on it.
    // TODO: move this to the form.js. It's already there for marker dragging only.
    function setLatLng(position) {
      var latInput = document.getElementById('legacy_legacy_site_latitude');
      var lngInput = document.getElementById('legacy_legacy_site_longitude');
      if (latInput && lngInput) {
        // A little hacky
        if (typeof position.lat === 'function') {
          // This came in from the marker drag event
          latInput.value = position.lat();
          lngInput.value = position.lng();
        } else {
          // This came in from the geocode result
          latInput.value = position.lat;
          lngInput.value = position.lng;
        }
      }

    }
  }

  // Geolocation
  var defaultRandomLocation = {lat:31.4181, lng:73.0776};
  var myLocationMarker = new params.google.maps.Marker({
    map: this.map,
    animation: params.google.maps.Animation.DROP,
    position: defaultRandomLocation,
    visible: false
  });

  if (navigator.geolocation) {
    addLocationButton(this.map, myLocationMarker, params);
  }
}