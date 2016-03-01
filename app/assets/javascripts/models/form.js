var CCMap = CCMap || {};

/**
 * Initialize the site form - requires jQuery
 * @constructor
 * @param {Object} params - The configuration paramters
 * @param {number} params.event_id
 * @param {function} [params.onCancel] - cancel callback
 */
CCMap.Form = function(params) {
  // TODO: remove simple_form on the server
  // Silly generated id because we're using simple_form on the server
  var form = document.getElementById('new_legacy_legacy_site');
  var header = document.getElementById('form-header');
  var cancelBtn = document.getElementById('cancel-form-btn');
  if (!params.event_id) {
    console.error('CCMap.Form requires an event_id');
    return;
  }
  var event_id = params.event_id;

  this.hydrate = function(site) {
    // Update the form action to update the site
    form.action = '/worker/incident/' + event_id + '/edit/' + site.id;

    // Loop over the site attribues and populate the corresponding inputs if they exist
    for (var field in site) {
      if (site.hasOwnProperty(field) && typeof form.elements['legacy_legacy_site[' + field + ']'] !== 'undefined') {
        form.elements['legacy_legacy_site[' + field + ']'].value = site[field];
      }
    }

    // Loop over the site.data attribues and populate the corresponding inputs if they exist
    for (var field in site.data) {
      if (site.data.hasOwnProperty(field) && typeof form.elements['legacy_legacy_site[' + field + ']'] !== 'undefined') {
        form.elements['legacy_legacy_site[' + field + ']'].value = site.data[field];
      }
    }

    // Update the form header title
    header.innerHTML = 'Edit Case ' + site.case_number;
  };

  // Cancel
  cancelBtn.addEventListener('click', function() {
    form.reset();
    form.scrollTop = 0;
    if (params.onCancel) {
      params.onCancel();
    }
  });

  // Submit
  form.addEventListener('submit', function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    $('.error, .alert-box').remove();
    var errorList = getErrors();
    if (errorList.length == 0){
      var data = buildData(this);
      $.ajax({
        type: "POST",
        url: this.action,
        data: data,
        success: function(data){
          if (data["id"] == undefined && data["updated"] == undefined){
            var html = "<div data-alert class='alert-box'>"+data+"<a href='#' class='close'>&times;</a></div>"
            $('.close').click(function(){
              $('form').prepend(html);
              $('.alert-box').remove();
            });
          } else if (data["updated"] != undefined) {
            var html = "<div data-alert class='alert-box'>"+data["updated"]["name"]+" was successfully saved<a href='#' class='close'>&times;</a></div>";
            $('form').prepend(html);
            $('.close').click(function(){
              $('.alert-box').remove();
            });
            new CCMap.Map('map-canvas',data["updated"]["legacy_event_id"],data["updated"]["latitude"],data["updated"]["longitude"],18).build(data["updated"]["id"]);
          } else {
            var html = "<div data-alert class='alert-box'>"+data['name']+" was successfully saved<a href='#' class='close'>&times;</a></div>";
            $('form').prepend(html);
            $('.close').click(function(){
              $('.alert-box').remove();
            });

            $('html,body').animate({scrollTop: 0});
            $('form')[0].reset();

            new CCMap.Map('map-canvas',data["legacy_event_id"],data["latitude"],data["longitude"],18).build(data["id"]);
          }
        },
        error: function(){
          alert('500 error');
        }
      });
    }else{
      $.each(errorList,function(i,v){
        $(v).parent().append("<small class='error'>can't be blank</small>")
      })
    }
    return false;
  });

  var getErrors = function(){
    var list = [];
    $.each($("form input.required"),function(i,v){
      if (v.value == ''){list.push(v)}
    });
    return list;
  }

  var buildData = function(form) {
    var serializedData = $(form).serialize();
    return serializedData;
  }
}
