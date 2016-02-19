$(document).ready(function() {
  var letsgobtn = document.getElementById('lets-go-btn');

  if (letsgobtn) {
    letsgobtn.addEventListener('click', function() {
      var locationSelect = document.getElementById('location-select');
      window.location = locationSelect.value;
    });
  }
});
