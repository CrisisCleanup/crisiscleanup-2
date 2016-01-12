$(document).on("ready page:load",function() {

    $( "#model_filters_button" ).click(function() {

        var verified = $("#verified_select").val();
        var active = $("#active_select").val();

        var current_url = window.location.href;
        if (current_url.indexOf("?") != -1) {
            current_url = current_url.slice(0, current_url.indexOf("?"))
        }
        current_url = current_url + "?"
        $( "select" ).each(function( i ) {
            var name = $(this).attr("id").replace("_select", "");
            var value = $(this).val();
            current_url = current_url + "" + name + "=" + value + "&";
        });
        window.location = current_url;
    });

    var vars = getUrlVars();
    for (i = 0; i < vars.length; i++) { 
        var key = vars[i];
        var value = vars[key];
        // if not undefined
        var element = "#" + key + "_select option[value='" + value + "']";
        $(element).attr("selected", "selected");
    }
});

function getUrlVars() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}
