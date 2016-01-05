
$(document).ready(function() {
	
	var path = $(location).attr('pathname');
	var dashboard = path.split('/')[1] == 'admin';	
	console.log(dashboard);
	var page = path.split('/')[2];
	var elem = '.'+page;
	var public_map = $('#public-map-canvas').length
	var worker_map = $('#worker-map-canvas').length
	
	if (dashboard){
		$('select').foundationSelect();
		$('.dashboard li').removeClass('active');
		$(elem).addClass('active');
		if ($(elem).parents('.has-dropdown').length) {
			$(elem).parents('.has-dropdown').addClass('active');
		}
	}
	// if a map is on the page get incident id
	if (public_map != 0 || worker_map != 0) {
		// if no incident id show blank map
		var id = typeof $('.m-id.hidden')[0] !== 'undefined' ? $('.m-id.hidden')[0].innerHTML : 'none';
		// if no pin is specified it will show all pins
		var pin = typeof $('.m-pin.hidden')[0] !== 'undefined' ? $('.m-pin.hidden')[0].innerHTML : 'all';
		// if its a public map build it.
		if (public_map != 0){
			var ccmap = new CCMAP('public-map-canvas', 6);
			google.maps.event.addDomListener(window,'ready',ccmap.buildPublicMap(pin));
		}
		// to do worker 

	}
});