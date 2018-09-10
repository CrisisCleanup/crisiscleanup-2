$(document).on('ready page:load', function() {
  $('.preview').on('click', function() {
    const html = $.parseHTML($('#form_html').val());
    $('#preview .lead').empty();

    $('#preview .lead').append(html);
  });
});