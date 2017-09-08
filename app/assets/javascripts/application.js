// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// CHANGE THIS LINE TO RECOMPILE JAVASCRIPT, TO GET NEW ICONS TO LOAD. 2016-07-31 9:29 am
// 
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require_tree ./plugins
//= require ./worker/sites.js
//= require ./scripts.js
//= require images
//= require_tree ./admin
//= require_tree ./models
//= require_tree ./other
//= require_tree ./static_pages
//= require_tree ./worker


$(document).ready(function(){
	$(document).foundation({
    equalizer: {
      equalize_on_stack: true,
    }
  });
});
