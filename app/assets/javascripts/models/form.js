var CCMap = CCMap || {};

/**
 * Initialize the site form - requires jQuery
 * @constructor
 * @param {Object} params - The configuration paramters
 * @param {number} params.event_id
 * @param {function} [params.onCancel] - cancel callback
 * @param {function} [params.onSave] - save callback
 */
CCMap.Form = function(params) {
  // TODO: remove simple_form on the server
  // Silly generated id because we're using simple_form on the server
  var self = this; // This is messy, but easier atm.
  var form = document.getElementById('new_legacy_legacy_site');
  var header = document.getElementById('form-header');
  var cancelBtn = document.getElementById('cancel-form-btn');
  var claimBtn = document.getElementById('claim-form-btn');
  var saveBtn = document.getElementById('save-form-btn');
  if (!params.event_id) {
    console.error('CCMap.Form requires an event_id');
    return;
  }
  var event_id = params.event_id;

  // Autopopulate the request_date field if empty (hydrate should overwrite this on edit forms)
  var date = new Date;
  var yyyy = date.getFullYear().toString();
  var mm = (date.getMonth()+1).toString(); // getMonth() is zero-based
  var dd  = date.getDate().toString();
  var dateStr = yyyy + '-' + (mm[1]?mm:"0"+mm[0]) + '-' + (dd[1]?dd:"0"+dd[0]);
  if (form && form.elements['legacy_legacy_site_request_date']) {
    form.elements['legacy_legacy_site_request_date'].value = dateStr;
  }

  this.hydrate = function(ccsite) {
    if (!form) {
      return;
    }

    // Update the form action to update the site
    form.action = '/worker/incident/' + event_id + '/edit/' + ccsite.site.id;

    // Change the Reset button label to "Cancel"
    if (cancelBtn) {
      $(cancelBtn).html("Cancel");
    }

    // Set the site so it can be updated on save
    this.ccsite = ccsite;

    // Loop over the site attribues and populate the corresponding inputs if they exist
    for (var field in ccsite.site) {
      if (ccsite.site.hasOwnProperty(field) && typeof form.elements['legacy_legacy_site[' + field + ']'] !== 'undefined') {
        form.elements['legacy_legacy_site[' + field + ']'].value = ccsite.site[field];
      }
    }

    // Loop over the site.data attribues and populate the corresponding inputs if they exist
    for (var field in ccsite.site.data) {
      if (ccsite.site.data.hasOwnProperty(field) && typeof form.elements['legacy_legacy_site[' + field + ']'] !== 'undefined') {
        var input = form.elements['legacy_legacy_site[' + field + ']'];
        // Deal with checkboxes. I'm honestly at a loss how to do this a better way.
        if (input.length === 2 && ccsite.site.data[field] === "y") {
          // assume it's a checkbox
          input[1].checked = true;
        } else {
          input.value = ccsite.site.data[field];
        }
      }
    }

    // Update or hide the claim/unclaim submit button
    if (InitialState.user.admin || ccsite.site.claimed_by === InitialState.user.org_id || !ccsite.site.claimed_by) {
      $(claimBtn).show();
      if (ccsite.site.claimed_by) {
        claimBtn.value = 'Unclaim & Save';
      } else {
        claimBtn.value = 'Claim & Save';
      }
    } else {
      $(claimBtn).hide();
    }

    // Update the form header title
    header.innerHTML = 'Edit Case ' + ccsite.site.case_number;
  };

  // Cancel on edit form. Reset new form.
  if (cancelBtn) {
    cancelBtn.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopImmediatePropagation();
      form.reset();
      form.scrollTop = 0;
      if (params.onCancel) {
        params.onCancel();
      }
    });
  }

  if (claimBtn) {
    claimBtn.addEventListener('click', function(e) {
      form.elements['legacy_legacy_site_claim'].value = true;
    });
  }

  if (saveBtn) {
    saveBtn.addEventListener('click', function(e) {
      form.elements['legacy_legacy_site_claim'].value = false;
    });
  }

  // Submit
  if (form) {
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      e.stopImmediatePropagation();
      $('.error, .alert-box').remove();
      var errorList = getErrors();
      if (errorList.length == 0) {
        var data = buildData(this);
        $.ajax({
          type: "POST",
          url: this.action,
          data: data,
          success: function(data) {
            if (data.duplicates) {
              var duplicatesList = $('<ul>', { id: "duplicates-list" });
              data.duplicates.forEach(function(dup) {
                duplicatesList.append(
                  '<li><a href="/worker/incident/' + dup.event_id + '/edit/' + dup.id + '" target="_blank">'
                  + dup.case_number
                  + ': '
                  + dup.address
                  + '</a></li>'
                );
              });
              var alertHtml = $(
                '<div data-alert class="alert-box info">'
                + '<p><strong>Possible Duplicates</strong></p>'
                + '<a href="#" class="close">&times;</a>'
                + '</div>'
              ).append(duplicatesList); 
              $('form').prepend(alertHtml);
            } else if (data.errors) {
              var errorList = $('<div>', { id: "error-list" });
              data.errors.forEach(function(error) {
                errorList.append('<p>' + error + '</p>');
              });
              var alertHtml = $('<div data-alert class="alert-box warning"><a href="#" class="close">&times;</a></div>').append(errorList); 
              $('form').prepend(alertHtml);
            } else if (data["id"] == undefined && data["updated"] == undefined) {
              var html = "<div data-alert class='alert-box'>"+data+"<a href='#' class='close'>&times;</a></div>";
              $('.close').click(function() {
                $('form').prepend(html);
                $('.alert-box').remove();
              });
            } else if (data["updated"] != undefined) {
              // Successful save on the edit form
              var nameStr = data.updated.case_number + " - " + data.updated.name;
              var html = "<div data-alert class='alert-box'>" + nameStr + " was successfully saved<a href='#' class='close'>&times;</a></div>";
              $('#alert-container').html(html);
              form.reset();
              form.scrollTop = 0;
              if (params.onSave) {
                params.onSave();
              }

              // update the site info
              // TODO: Set up the legacy_organization association everywhere. name only.
              if (data.updated.legacy_organization) {
                data.updated.org_name = data.updated.legacy_organization.name
              }
              self.ccsite.site = data.updated;

              // update the map marker
              self.ccsite.marker.setIcon(self.ccsite.generateIconFilename());
              var lat_lng = new google.maps.LatLng(parseFloat(self.ccsite.site.latitude), parseFloat(self.ccsite.site.longitude));
              self.ccsite.marker.setPosition(lat_lng);

              // update the infobox
              self.ccsite.updateInfoboxHtml();
            } else {
              // Successful save on the new site form
              var nameStr = data.case_number + " - " + data.name;
              var html = "<div data-alert class='alert-box'>" + nameStr + " was successfully saved<a href='#' class='close'>&times;</a></div>";
              $('#alert-container').html(html);
              form.reset();
              form.scrollTop = 0;
            }
            form.scrollTop = 0;
            window.scrollTo(0,0);
          },
          error: function(){
            alert('500 error');
          }
        });
      } else {
        $.each(errorList,function(i,v){
          $(v).parent().append("<small class='error'>can't be blank</small>")
        })
      }
      return false;
    });
  }

  var getErrors = function(){
    var list = [];
    $.each($("form input.required"),function(i,v) {
      if (v.value == ''){list.push(v)}
    });
    return list;
  }

  // Most of this is hacking around the simple_form stuff we're not using anyway...
  var buildData = function(form) {
    var postData = {
      legacy_legacy_site: {
        data: {}
      }
    };

    // TODO: maybe make this suck slighly less by dynamically building it server
    //   side based on the current state of the LegacySite model.
    //   The params would be great.
    var topLevelFields = [
      "address",
      "blurred_latitude",
      "blurred_longitude",
      "case_number",
      "claim",
      "claimed_by",
      "legacy_event_id",
      "latitude",
      "longitude",
      "name",
      "city",
      "county",
      "state",
      "zip_code",
      "phone1",
      "phone2",
      "reported_by",
      "requested_at",
      "status",
      "work_type",
      "data",
      "created_at",
      "updated_at",
      "request_date",
      "appengine_key",
      "work_requested",
      "skip_duplicates"
    ];
    // create the data object from all of the inputs that are not top level
    var inputs = form.elements;
    for (var i = 0; i < inputs.length; i++) {
      if (inputs[i].type === 'button') { continue; }
      if (inputs[i].type === 'submit') { continue; }
      // strip that simple_form crap out.
      var fieldName = /\[(.*)\]/.exec(inputs[i].name);
      if (fieldName && fieldName.length > 1) {
        fieldName = fieldName[1];
        if (topLevelFields.indexOf(fieldName) > -1) {
          // Put it top level
          // deal with the checkboxes...
          if (inputs[i].type === 'checkbox') {
            if (inputs[i].checked) {
              postData.legacy_legacy_site[fieldName] = inputs[i].value;
            }
          } else {
            postData.legacy_legacy_site[fieldName] = inputs[i].value;
          }
        } else {
          // Put it in data
          // deal with the checkboxes...
          if (inputs[i].type === 'checkbox') {
            if (inputs[i].checked) {
              postData.legacy_legacy_site.data[fieldName] = inputs[i].value;
            }
          } else {
            postData.legacy_legacy_site.data[fieldName] = inputs[i].value;
          }
        }
      } else {
        postData[inputs[i].name] = inputs[i].value;
      }
    }
    return postData;
  }
}
