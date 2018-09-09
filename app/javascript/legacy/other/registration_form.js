$(document).on('ready page:load', () => {
  $('.contact_form').on('click', '.remove_fields', function (event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.contact').remove();
    event.preventDefault();
  });
  $('.contact_form').on('click', '.add_fields', function (event) {
    const time = new Date().getTime();
    const regexp = new RegExp($(this).data('id'), 'g');
    $(this).before($(this).data('fields').replace(regexp, time));
    event.preventDefault();
  });
});