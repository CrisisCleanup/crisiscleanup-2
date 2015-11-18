$(function() {
    $( "#submit_sort_order" ).click(function() {
        var sort_order = $("#sort_order").val();
        var current_url = window.location.href;
        if (current_url.indexOf("?") != -1) {
            current_url = current_url.slice(0, current_url.indexOf("?"))
        }
        window.location = current_url + "?order=" + sort_order
    });
    var myParam = location.search.split('order=')[1]
    if (myParam) {
        $("#sort_order").val(myParam);
    }
});