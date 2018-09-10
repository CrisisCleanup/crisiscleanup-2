$(document).on('ready page:load', function() {
  $('#model_filters_button').click(function() {

    let current_url = window.location.href;
    if (current_url.indexOf('?') != -1) {
      current_url = current_url.slice(0, current_url.indexOf('?'));
    }
    current_url = `${current_url}?`;
    $('select').each(function() {
      const name = $(this).attr('id').replace('_select', '');
      const value = $(this).val();
      current_url = `${current_url}${name}=${value}&`;
    });
    window.location = current_url;
  });

  const vars = getUrlVars();
  for (let i = 0; i < vars.length; i += 1) {
    const key = vars[i];
    const value = vars[key];
    var element;
    // TODO: figure out what's going on here and remove this band-aid
    if (typeof value !== 'undefined') {
      element = `#${key}_select option[value='${value}']`;
    }
    $(element).attr('selected', 'selected');
  }
});

function getUrlVars() {
  let vars = [],
    hash;
  const hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
  for (let i = 0; i < hashes.length; i++) {
    hash = hashes[i].split('=');
    vars.push(hash[0]);
    vars[hash[0]] = hash[1];
  }
  return vars;
}