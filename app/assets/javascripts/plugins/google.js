
window.google = window.google || {};
google.maps = google.maps || {};
(function() {

  function getScript(src) {
    document.write('<' + 'script src="' + src + '"><' + '/script>');
  }

  var modules = google.maps.modules = {};
  google.maps.__gjsload__ = function(name, text) {
    modules[name] = text;
  };

  google.maps.Load = function(apiLoad) {
    //console.log("loadMap");
  };

  var loadScriptTime = (new Date).getTime();
  getScript("https://maps.googleapis.com/maps/api/js?key=AIzaSyAXkt-1qLdIKnPUkx0PmipJNc0DwlXbMNw");
})();
