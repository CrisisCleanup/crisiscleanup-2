$(document).on('ready page:load', () => {
  $('.my_org_contacts_form').on('click', '.remove_fields', function (event) {
    $(this).prev('input[type=hidden]').val('true');
    $(this).closest('.contact').hide();
    $('.add_fields').show();
    event.preventDefault();
  });
  $('.my_org_contacts_form').on('click', '.add_fields', function (event) {
    const time = new Date().getTime();
    const regexp = new RegExp($(this).data('id'), 'g');
    $(this).before($(this).data('fields').replace(regexp, time));
    $('.add_fields').hide();
    event.preventDefault();
  });
});