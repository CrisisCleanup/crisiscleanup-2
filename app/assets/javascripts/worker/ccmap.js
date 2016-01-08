// build map with all of the pins clustered
var markers = [];
var map;
var markerCluster;
var markerBounds = new google.maps.LatLngBounds();
function CCMAP(elm, event_id,lat,lng,zoom){
	this.canvas = document.getElementById(elm);
	this.worker =  elm != 'public-map-canvas' ? true : false;
	console.log(event_id);
	this.incident = event_id;
	this.zoom = typeof zoom !== 'undefined' ? zoom : 4;
	this.latitude = typeof lat !== 'undefined' ? lat : 39;
   	this.longitude = typeof lng !== 'undefined' ? lng : -90;
	this.options = {
	  center: new google.maps.LatLng(this.latitude, this.longitude),
	  zoom: this.zoom,
	  mapTypeId: google.maps.MapTypeId.ROADMAP,
	  scrollwheel: false    
	}
	map = new google.maps.Map(this.canvas, this.options)
}

CCMAP.prototype.buildMarkers = function(id){
	$('.map-wrapper').append('<div class="loading"></div>')
	this.incident = id;
	route = this.worker ? "/api/map?legacy_event_id="+id : "/api/public/map?legacy_event_id="+id
	lat = this.worker ? "latitude" : "blurred_latitude";
	lng = this.worker ? "longitude" : "blurred_longitude";
	$.ajax({
	  	type: "GET",
	  	url: route,
	  	success: function(data){
			clearOverlays();
			if (data.length > 0){
				$.each(data, function(index, obj) {
				 	markerBounds.extend(new google.maps.LatLng(parseFloat(obj[lat]), parseFloat(obj[lng])));
			  		var marker = new google.maps.Marker({
	          			position: new google.maps.LatLng(parseFloat(obj[lat]), parseFloat(obj[lng])),
	            		map: map
			        });
			        markers.push(marker);
			    
			    })
			    markerCluster = new MarkerClusterer(map, markers);
			    map.fitBounds(markerBounds);
				$('.loading').remove();    
			}else{alert("no reported incidents");}			
  		},
  		error: function(){
  			alert('500 error');
 		 }
	})	
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