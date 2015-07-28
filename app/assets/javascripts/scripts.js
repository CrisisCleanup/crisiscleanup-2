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
	
	if(workerMap != 0){	
		
		var id = $('.m-id.hidden')[0].innerHTML;
		var ccmap = new CCMAP('map-canvas',id);

		google.maps.event.addDomListener(window, 'ready',ccmap.build());
	

	}
	
  	

});