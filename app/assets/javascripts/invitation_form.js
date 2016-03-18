$(document).ready(function(){
	$(".invitation-confirmation-button").attr('disabled', 'disabled');
	$("#user_accepted_terms").change(function() {
		var checked = $('#user_accepted_terms').is(':checked');
		if (checked) {
			$(".invitation-confirmation-button").removeAttr('disabled');
		} else {
			$(".invitation-confirmation-button").attr('disabled', 'disabled');
		}
	})
});