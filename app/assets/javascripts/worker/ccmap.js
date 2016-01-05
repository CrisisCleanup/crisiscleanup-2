// build map with all of the pins clustered
var markers = [];
function CCMAP(elm, event_id,lat,lng,zoom){
	this.canvas = document.getElementById(elm);
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

}

CCMAP.prototype.buildPublicMap = function(pin){
	// first build empty map
	$('.map-wrapper').prepend('<div class="loading"></div>')
	var map = new google.maps.Map(this.canvas, this.options)
	
	if (this.incident != 'none' && pin == 'all'){
		
		$.ajax({
		  	type: "GET",
		  	url: "/api/public/map?legacy_event_id="+this.incident,
		  	success: function(data){
				$.each(data, function(index, obj) {
			  		var marker = new google.maps.Marker({
	          			position: new google.maps.LatLng(parseFloat(obj["blurred_latitude"]), parseFloat(obj["blurred_longitude"])),
	            		map: map
			        });
			        markers.push(marker);

			    })
			    $('.loading').remove();
	  		},
	  		error: function(){
	  			alert('500 error');
	 		 }
		})
	}else{
		$('.loading').remove();
	}



}
CCMAP.prototype.clearOverlays == function() {
	if (markers.length > 0) {
	  for (i in markers) {
	    markers[i].setMap(null);
	  }
	}
}