$(document).ready(function () {
  var path = $(location).attr('pathname');
  var pathArray = path.split('/');
  var dashboard = pathArray[1] === 'admin';
  var page = pathArray[2];
  var elem = '.' + page;

  if (dashboard) {
    $('select').foundationSelect();
    $('.dashboard li').removeClass('active');
    $(elem).addClass('active');
    if ($(elem).parents('.has-dropdown').length) {
      $(elem).parents('.has-dropdown').addClass('active');
    }
  }

});
