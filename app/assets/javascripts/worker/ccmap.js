function CCMAP(elm, event_id,lat,lng,zoom){
	this.canvas = document.getElementById(elm);
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

CCMAP.prototype.build = function(pin){
	var map = new google.maps.Map(this.canvas, this.options)
	this.pin = typeof pin !== 'undefined' ? pin : 'all';
	if (this.pin == 'all'){
			$.ajax({
			  	type: "GET",
			  	url: "/api/map?legacy_event_id="+this.incident,
			  	success: function(data){
					
					$.each(data, function(index, obj) {
				  		var marker1 = new google.maps.Marker({
				  		position: new google.maps.LatLng(parseFloat(obj["latitude"]), parseFloat(obj["longitude"])),
				  	    map: map
				  	});
				  })
		  		},
		  		error: function(){
		  			alert('500 error');
		 		 }
			})
	}else if(this.pin != 'init'){
		$.ajax({
		  	type: "GET",
		  	url: "/api/map?pin="+this.pin,
		  	success: function(data){
		  		var marker1 = new google.maps.Marker({
		  			position: new google.maps.LatLng(parseFloat(data["latitude"]), parseFloat(data["longitude"])),
		  	    	map: map
		  		});
	  		},
	  		error: function(){
	  			alert('500 error');
	 		 }
		});
	}
  		

}
