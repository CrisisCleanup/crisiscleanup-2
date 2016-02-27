$(document).ready(function(){
	$(".invitation-confirmation-button").attr('disabled', 'disabled');
	$("#accept-terms").change(function() {
		var checked = $('#accept-terms').is(':checked');
		if (checked) {
			$(".invitation-confirmation-button").removeAttr('disabled');
		}
	})
});