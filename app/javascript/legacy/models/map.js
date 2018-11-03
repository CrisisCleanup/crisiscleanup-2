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

window.mobilecheck = function() {
  var check = false;
  (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
  return check;
};

export default function(params) {
  let $infobox = $('#map-infobox');

  let allSites = [];
  let activeMarkers = [];
  const markerClustererOptions = {
    maxZoom: 11,
    styles: [
      {
        textColor: 'black',
        url: window.image_path('map_icons/m1.png'),
        height: 53,
        width: 52
      },
      {
        textColor: 'black',
        url: window.image_path('map_icons/m2.png'),
        height: 56,
        width: 55
      },
      {
        textColor: 'black',
        url: window.image_path('map_icons/m3.png'),
        height: 66,
        width: 65
      },
      {
        textColor: 'black',
        url: window.image_path('map_icons/m4.png'),
        height: 78,
        width: 77
      },
      {
        textColor: 'black',
        url: window.image_path('map_icons/m5.png'),
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
  this.markerClusterer = new window.MarkerClusterer(this.map, [], markerClustererOptions);

  this.map.addListener('click', function() {
    $('#filters-anchor').click();
    $infobox.hide();
    this.showFilters();
  }.bind(this));

  let self = this;
  self.autocompleteTrackingMarker = null;

  function getAutocompleteTrackingMarker() {
    return self.autocompleteTrackingMarker;
  }

  // Setting this up this way just in case we end up with dynamic filters per incident.
  // Eventually, it could require a filters[] param, for example.
  // This could also end up in the setEventId method.
  let filters = new Filters({
    onUpdate: populateMap.bind(this),
    workTypes: document.getElementById('legacy_legacy_site_work_type'),
    isPublicMap: this.public_map
  });

  this.setEventId = function(event_id) {
    $('#map-infobox').hide();
    this.event_id = event_id;
    // TODO: refactor this nonsense.
    if (this.form_map) {
      setupAddressAutocomplete.call(this);
      let form = new Form({
        event_id: this.event_id,
        getAutocompleteTrackingMarker: getAutocompleteTrackingMarker
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
    let $moveWorksiteView = $('#move-worksite-view');
    let $wrongLocationView = $('#wrong-location-view');

    if ($filtersView.hasClass('hide')) {
      $formView.addClass('hide');
      $historyView.addClass('hide');
      $moveWorksiteView.addClass('hide');
      $wrongLocationView.addClass('hide');
      $filtersView.removeClass('hide');
    }
  };
  
  this.showForm = function() {
    // Hacky way to hide the form alert box between edits.
    let $formView = $('#form-view');
    $formView.find('.alert-box a.close').click();

    let $filtersView = $('#filters-view');
    let $historyView = $('#history-view');
    let $moveWorksiteView = $('#move-worksite-view');
    let $wrongLocationView = $('#wrong-location-view');

    if ($formView.hasClass('hide')) {
      $filtersView.addClass('hide');
      $historyView.addClass('hide');
      $moveWorksiteView.addClass('hide');
      $wrongLocationView.addClass('hide');
      $formView.removeClass('hide');
    }
  };

  this.showHistory = function() {
    let $formView = $('#form-view');
    $formView.find('.alert-box a.close').click();

    let $filtersView = $('#filters-view');
    let $historyView = $('#history-view');
    let $moveWorksiteView = $('#move-worksite-view');
    let $wrongLocationView = $('#wrong-location-view');

    if ($historyView.hasClass('hide')) {
      $filtersView.addClass('hide');
      $formView.addClass('hide');
      $moveWorksiteView.addClass('hide');
      $wrongLocationView.addClass('hide');
      $historyView.removeClass('hide');
    }
  };
  
  this.showMoveWorksite = function() {
    let $formView = $('#form-view');
    $formView.find('.alert-box a.close').click();

    let $filtersView = $('#filters-view');
    let $historyView = $('#history-view');
    let $moveWorksiteView = $('#move-worksite-view');
    let $wrongLocationView = $('#wrong-location-view');

    if ($moveWorksiteView.hasClass('hide')) {
      $filtersView.addClass('hide');
      $formView.addClass('hide');
      $historyView.addClass('hide');
      $wrongLocationView.addClass('hide');
      $moveWorksiteView.removeClass('hide');
    }
  };  
  
  this.showWrongLocation = function() {
    let $formView = $('#form-view');
    $formView.find('.alert-box a.close').click();

    let $filtersView = $('#filters-view');
    let $historyView = $('#history-view');
    let $moveWorksiteView = $('#move-worksite-view');
    let $wrongLocationView = $('#wrong-location-view');

    if ($wrongLocationView.hasClass('hide')) {
      $filtersView.addClass('hide');
      $formView.addClass('hide');
      $historyView.addClass('hide');
      $moveWorksiteView.addClass('hide');
      $wrongLocationView.removeClass('hide');
    }
  }; 

  function zoomToMarkerLocal(id) {
    let matchArray = $.grep(allSites, function(site) { return site.site.id === id; });
    if (matchArray.length > 0) {
      let marker = matchArray[0].marker;
      this.map.setZoom(17);
      this.map.setCenter(marker.getPosition());
      marker.setAnimation(params.google.maps.Animation.BOUNCE);
      // Stop the animation after awhile
      setTimeout(function() {
        marker.setAnimation(null);
      }, 1000);
    } else {
      Raven.captureMessage("Matching site not found.", {level: 'warning'});
    }
  }
  let zoomToMarker = zoomToMarkerLocal.bind(this);

  function setupSearch(siteList) {
    let $searchBtn = $('#map-search-btn');
    // Initialize the search typeahead
    // TODO: this shouldn't be loaded or even rendered on every page.
    if ($searchBtn) {
      var siteBh = new window.Bloodhound({
        datumTokenizer: function(obj) {
          return window.Bloodhound.tokenizers.whitespace(obj.siteStr);
        },
        queryTokenizer: window.Bloodhound.tokenizers.whitespace,
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
        // infobox popup
        
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
            data.forEach(function(obj) {
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
            data.forEach(function(obj) {
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
    if (this.public_map) {
      route = "/api/public/map/" + this.event_id + "/" + PAGE_SIZE + "/";
    } else {
      route = "/api/map/" + this.event_id + "/" + PAGE_SIZE + "/";
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
      if (city.value !== "") { num_values++ }
      if (state.value !== "") { num_values++ }
      if (zip.value !== "") { num_values++ }

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
      self.autocompleteTrackingMarker = new params.google.maps.Marker({
        draggable: true,
        position: place.geometry.location,
        map: map
      });

      self.autocompleteTrackingMarker.addListener('drag', function() {
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