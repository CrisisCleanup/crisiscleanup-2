var ccmap;
$(document).ready(function(){
	var public_map = $('#public-map-canvas').length
	if (public_map != 0){
		var id = typeof $('.m-id.hidden')[0] !== 'undefined' ? $('.m-id.hidden')[0].innerHTML : 'none';
		ccmap = new CCMAP('public-map-canvas', id);
		
		$( ".select_incident" ).change(function() {
		    var event_id = $(".select_incident").val();

		    ccmap.buildMarkers(event_id);
		});
	}
});
	