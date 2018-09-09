/* global google */

export function isMobileDeviceByUserAgent() {
  if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
    return true;
  }
  return false;
}

export function isMobileDeviceByMedia() {
  const isMobile = window.matchMedia("only screen and (max-width: 760px");

  if (isMobile.matches) {
    return true;
  }
  return false
}

export function setMarkerLatLng(position) {
  let latInput = document.getElementById('legacy_legacy_site_latitude');
  let lngInput = document.getElementById('legacy_legacy_site_longitude');
  if (typeof position.lat === 'function') {
    latInput.value = position.lat();
    lngInput.value = position.lng();
  } else {
    latInput.value = position.coords.latitude;
    lngInput.value = position.coords.longitude;
  }
}

export function addMarker(map, position, zoomLevel) {
  let marker = new google.maps.Marker({
    draggable: true,
    position: position,
    map: map
  });
  map.setCenter(position);
  map.setZoom(zoomLevel);
  marker.addListener('drag', function() {
    setMarkerLatLng(this.position);
  });

  return marker;
}

export function disableAddressFields() {
  $("#legacy_legacy_site_address").prop('disabled', true).val('UNKNOWN');
  $("#legacy_legacy_site_city").prop('disabled', true).val('UNKNOWN');
  $("#legacy_legacy_site_county").prop('disabled', true).val('UNKNOWN');
  $("#legacy_legacy_site_state").prop('disabled', true).val('UNKNOWN');
  $("#legacy_legacy_site_country").prop('disabled', true).val('UNKNOWN');
  $("#legacy_legacy_site_zip_code").prop('disabled', true).val('UNKNOWN');
}

export function resetAddressFields() {
  $("#legacy_legacy_site_address").prop('disabled', false).val('');
  $("#legacy_legacy_site_city").prop('disabled', false).val('');
  $("#legacy_legacy_site_county").prop('disabled', false).val('');
  $("#legacy_legacy_site_state").prop('disabled', false).val('');
  $("#legacy_legacy_site_country").prop('disabled', false).val('');
  $("#legacy_legacy_site_zip_code").prop('disabled', false).val('');
}

export function detectLocation(cb, errorCb) {
  if(navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (position) {
      cb(position);
    }, function () {
      errorCb();
      alert('There has been a problem detecting your location!  You may have geolocation deactivated in your browser or mobile device privacy settings.')
    });
  }
}

export function addLocationButton(map, marker, params) {
  var controlDiv = document.createElement('div');

  var firstChild = document.createElement('button');
  firstChild.style.backgroundColor = '#fff';
  firstChild.style.border = 'none';
  firstChild.style.outline = 'none';
  firstChild.style.width = '28px';
  firstChild.style.height = '28px';
  firstChild.style.borderRadius = '2px';
  firstChild.style.boxShadow = '0 1px 4px rgba(0,0,0,0.3)';
  firstChild.style.cursor = 'pointer';
  firstChild.style.marginRight = '10px';
  firstChild.style.padding = '0px';
  firstChild.title = 'Your Location';
  controlDiv.appendChild(firstChild);

  var secondChild = document.createElement('div');
  secondChild.style.margin = '5px';
  secondChild.style.width = '18px';
  secondChild.style.height = '18px';
  secondChild.style.backgroundImage = 'url(https://maps.gstatic.com/tactile/mylocation/mylocation-sprite-1x.png)';
  secondChild.style.backgroundSize = '180px 18px';
  secondChild.style.backgroundPosition = '0px 0px';
  secondChild.style.backgroundRepeat = 'no-repeat';
  secondChild.id = 'you_location_img';
  firstChild.appendChild(secondChild);

  params.google.maps.event.addListener(map, 'dragend', function() {
    $('#you_location_img').css('background-position', '0px 0px');
  });

  firstChild.addEventListener('click', function() {
    var imgX = '0';
    var animationInterval = setInterval(function(){
      if(imgX == '-18') imgX = '0';
      else imgX = '-18';
      $('#you_location_img').css('background-position', imgX+'px 0px');
    }, 500);

    let cb = function(position) {
      let latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      marker.setPosition(latlng);
      marker.setVisible(true);
      map.setCenter(latlng);
      map.setZoom(14);
      clearInterval(animationInterval);
      $('#you_location_img').css('background-position', '-144px 0px');
    };
    detectLocation(cb);
  });

  controlDiv.index = 1;
  map.controls[params.google.maps.ControlPosition.RIGHT_BOTTOM].push(controlDiv);
}