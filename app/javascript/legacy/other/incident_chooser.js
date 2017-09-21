$(document).ready(function(){
	$("#incident-chooser").change(function() {
		window.location = "/worker/incident-chooser?id=" + $("#incident-chooser").val();// + "&path=" + window.location.pathname
	});
})