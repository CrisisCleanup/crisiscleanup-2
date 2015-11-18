  $(function() {
    var siteAttributes = <%= @site_json.html_safe %>;
    for (i in siteAttributes) {

 
      var attr = "#legacy_legacy_site_" + i;
      var elm = $(attr).val(siteAttributes[i]);
    }
    // TODO Make this work for HSTore data as well.
    // for (i in siteAttributes.data)
  });