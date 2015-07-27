function CCMAP(elm, event_id,lat,lng){
	this.canvas = document.getElementById(elm);
	this.incident = event_id;

	this.latitude = typeof lat !== 'undefined' ? lat : 39;
   	this.longitude = typeof lng !== 'undefined' ? lng : -90;
	
	this.options = {
	  center: new google.maps.LatLng(this.latitude, this.longitude),
	  zoom: 4,
	  mapTypeId: google.maps.MapTypeId.ROADMAP,
	  scrollwheel: false    
	}
}

CCMAP.prototype.build = function(){
	var map = new google.maps.Map(this.canvas, this.options)
	$.ajax({
		  	type: "GET",
		  	url: "/api/map?legacy_event_id="+this.incident,
		  	success: function(data){
				
				$.each(data, function(index, obj) {
			  	debugger;
			  	var marker1 = new google.maps.Marker({
			  		position: new google.maps.LatLng(parseFloat(obj["latitude"]), parseFloat(obj["longitude"])),
			  	    map: map
			  	});
			  })
	  		},
	  		error: function(){
	  			alert('500 error');
	 		 }
		});  		

}
