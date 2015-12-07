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
            console.log("select each" + $(this).attr("id") );
            var name = $(this).attr("id").replace("_select", "");
            var value = $(this).val();
            current_url = current_url + "" + name + "=" + value + "&";
        });
        window.location = current_url;
    });

    var vars = getUrlVars();
    console.log(vars);
    console.log(vars.length);
    for (i = 0; i < vars.length; i++) { 
        console.log("get vars");
        var key = vars[i];
        var value = vars[key];
        console.log(key);
        console.log(value);
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
