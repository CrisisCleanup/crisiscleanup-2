$(document).on("ready page:load",function() {
	var path = $(location).attr('pathname');
	var dashboard = path.split('/')[1] == 'admin';	
	var page = path.split('/')[2];
	var elem = '.'+page;
	var workerMap = $('.worker-dashboard #map-canvas').length
	
	if (dashboard){
		$('select').foundationSelect();
		$(document).foundation();
		$('.dashboard li').removeClass('active');
		$(elem).addClass('active');
		if ($(elem).parents('.has-dropdown').length) {
			$(elem).parents('.has-dropdown').addClass('active');
		}
	}
	// if a map is on the page
	if(workerMap != 0){	
		// get incident id
		var id = $('.m-id.hidden')[0].innerHTML;
		// get pin to determine which pins, if any or all to display
		var pin = $('.m-pin.hidden')[0].innerHTML;	
		var ccmap = new CCMAP('map-canvas',id);
		google.maps.event.addDomListener(window, 'ready',ccmap.build(pin));
	}
	
  	

});