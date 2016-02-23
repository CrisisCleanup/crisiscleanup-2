$(document).ready(function() {
  var letsgobtn = document.getElementById('lets-go-btn');

  if (letsgobtn) {
    letsgobtn.addEventListener('click', function() {
      var locationSelect = document.getElementById('location-select');
      if (locationSelect.value === "") { return; }
      window.location = locationSelect.value;
    });
  }
});
