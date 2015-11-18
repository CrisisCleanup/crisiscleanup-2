$(function() {
    $( "#organization_filters_button" ).click(function() {
        var verified = $("#verified_select").val();
        var active = $("#active_select").val();

        var current_url = window.location.href;
        if (current_url.indexOf("?") != -1) {
            current_url = current_url.slice(0, current_url.indexOf("?"))
        }
        window.location = current_url + "?verified=" + verified + "&active=" + active;
    });
    var active = location.search.split('active=')[1]
    if (active) {
        $("#active_select").val(active);
    }
    var verified = location.search.split('verified=')[1]

    if (verified) {
    	if (verified.indexOf("&") != -1) {
    	    verified = verified.slice(0, verified.indexOf("&"))
    	}
        $("#verified_select").val(verified);
    }
});
