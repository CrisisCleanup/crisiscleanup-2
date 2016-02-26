var CCMap = CCMap || {};

// build map with all of the pins clustered
CCMap.UnclaimedStatusColorMap = {
  "Open, unassigned": "orange",
  "Open, assigned": "yellow",
  "Open, partially completed": "yellow",
  "Open, partially completed": "yellow",
  "Closed, completed": "green",
  "Closed, incomplete": "gray",
  "Closed, out of scope": "gray",
  "Closed, done by others": "gray",
  "Closed, no help wanted": "xgray",
  "Closed, rejected": "xgray",
  "Closed, duplicate": "xgray"
};

CCMap.Site = function(params) {
  var $infobox = $('#map-infobox');

  this.map = params.map;
  this.ccmap = params.ccmap;
  this.site = params.site;
  this.marker = new google.maps.Marker({
    position: params.position,
    map: params.map,
    icon: generateIconFilename.call(this)
  });
  this.marker.addListener("click", function() {
    if (this.ccmap.public_map) {
      toPublicInfoboxHtml.call(this);
    } else {
      toInfoboxHtml.call(this);
    }
    $infobox.show();
    this.ccmap.showFilters();
  }.bind(this));

  // TODO: check if the file exists on the server or some other validation here.
  function generateIconFilename() {
    var color;
    if (this.site.claimed_by) {
      color = CCMap.UnclaimedStatusColorMap[this.site.status];
    } else {
      color = "red";
    }
    // this is the key sent to the image_path function in app/assets/javascripts/images.js.erb
    return image_path('map_icons/' + this.site.work_type.replace(' ', '_') + '_' + color + '.png');
  }

  /**
   * Takes a legacy_site obj and returns an html table (string) of the attributes
   * for the public map
   */
  function toPublicInfoboxHtml() {
    var caseNumberText = document.createTextNode('Case Number: ' + this.site.case_number);
    var caseNumberH4 = document.createElement('h4')
    caseNumberH4.appendChild(caseNumberText);
    $infobox.html(caseNumberH4);

    var notice = document.createTextNode('Name, Address, Phone Number are removed from the public map');
    var noticeP = document.createElement('p')
    noticeP.appendChild(notice);
    $infobox.append(noticeP);

    var addressString = 'Address: ' + this.site.address + ', ' + this.site.city + ', ' + this.site.state;
    if (this.site.zip_code) {
      addressString += '  ' + this.site.zip_code;
    }
    var addressText = document.createTextNode(addressString);
    var addressP = document.createElement('p')
    addressP.appendChild(addressText);
    $infobox.append(addressP);

    var workTypeText = document.createTextNode('Work Type: ' + this.site.work_type);
    var workTypeP = document.createElement('p')
    workTypeP.appendChild(workTypeText);
    $infobox.append(workTypeP);

    var statusText = document.createTextNode('Status: ' + this.site.status);
    var statusP = document.createElement('p')
    statusP.appendChild(statusText);
    $infobox.append(statusP);
  }

  /**
   * Takes a legacy_site obj and returns an html table (string) of the attributes
   */
  function toInfoboxHtml() {
    var table = document.createElement('table');

    // Create an object of key value pairs to display
    var displayObj = {
      "Case Number": this.site.case_number,
      "Name": this.site.name
    };

    // Requests
    if (this.site.data && this.site.data.work_requested) {
      displayObj["Requests"] = this.site.data.work_requested;
    }

    // Address
    displayObj["Address"] = this.site.address + ", " + this.site.city + ", " + this.site.state;

    // Test for zip_code. I don't see any zip codes in the current data
    if (this.site.zip_code) {
      displayObj["Address"] += "  " + this.site.zip_code;
    }

    // Data field
    if (this.site.data) {
      // Phone field
      var phone = [];
      if (this.site.data.phone1 && this.site.data.phone1.length > 10) {
        phone.push(this.site.data.phone1);
      }
      if (this.site.data.phone2 && this.site.data.phone2.length > 10) {
        phone.push(this.site.data.phone2);
      }
      if (phone.length > 0) {
        displayObj["Phone"] = phone.join(', ');
      }
      // end Phone field

      // data hstore field stuff
      var details = formattedDetails(this.site.data);
      if (details) {
        displayObj["Details"] = details;
      }
    }

    for (var key in displayObj) {
      if (displayObj.hasOwnProperty(key)) {
        table.appendChild(
          createTableRow(
            document.createTextNode(key + ":"),
            document.createTextNode(displayObj[key])
          )
        );
      }
    }

    // status dropdown
    var statusDropdown = document.createElement('select');
    statusDropdown.onchange = statusSelect.bind(this);
    var statusOptions = [
      "Open, unassigned",
      "Open, assigned",
      "Open, partially completed",
      "Open, partially completed",
      "Closed, completed",
      "Closed, incomplete",
      "Closed, out of scope",
      "Closed, done by others",
      "Closed, no help wanted",
      "Closed, rejected",
      "Closed, duplicate"
    ];
    statusOptions.forEach(function(optionLabel) {
      var option = document.createElement('option');
      if (optionLabel === this.site.status) {
        option.selected = 'selected';
      }
      option.appendChild(document.createTextNode(optionLabel));
      statusDropdown.appendChild(option);
    }.bind(this));
    table.appendChild(
      createTableRow(
        document.createTextNode('Status:'),
        statusDropdown
      )
    );

    // claimed by
    if (this.site.claimed_by) {
      table.appendChild(
        createTableRow(
          document.createTextNode('Claimed By:'),
          document.createTextNode(this.site.org_name)
        )
      );
    }

    // action buttons
    // TODO: a button class would be cool here, so we could attach the click event callbacks and whatnot.
    var actionButtons = {};
    if (this.site.claimed_by) {
      actionButtons["Contact Organization"] = contactOrg.bind(this);
    }

    actionButtons["Printer Friendly"] = print.bind(this);

    actionButtons["Edit"] = edit.bind(this);

    if (this.site.claimed_by) {
      actionButtons['Unclaim'] = claim.bind(this);
    } else {
      actionButtons['Claim'] = claim.bind(this);
    }
    var buttonRow = document.createElement('tr');
    var buttonCell = document.createElement('td');
    buttonCell.setAttribute('colspan', '2');
    for (var key in actionButtons) {
      if (actionButtons.hasOwnProperty(key)) {
        var button = document.createElement('a');
        button.className = 'button tiny';
        button.appendChild(document.createTextNode(key));
        button.onclick = actionButtons[key];
        buttonCell.appendChild(button);
      }
    }
    buttonRow.appendChild(buttonCell);
    table.appendChild(buttonRow);

    $infobox.html(table);
  }

  /**
   * Takes a legacy_site.data obj and returns a string of details to show in the infobox
   */
  function formattedDetails(data) {
    // TODO: clean this up once some of these fields are moved to the primary, LegacySite, model
    var blackList = [
      'address_digits',
      'address_metaphone',
      'assigned_to',
      'city_metaphone',
      'claim_for_org',
      'county',
      'cross_street',
      'damage_level',
      'date_closed',
      'do_not_work_before',
      'event',
      'event_name',
      'habitable',
      'hours_worked_per_volunteer',
      'ignore_similar',
      'initials_of_resident_present',
      'inspected_by',
      'landmark',
      'member_of_assessing_organization',
      'modified_by',
      'name_metaphone',
      'phone1', // This is being shown in its own field
      'phone2', // This is being shown in its own field
      'phone_normalised',
      'prepared_by',
      'priority',
      'release_form',
      'temporary_address',
      'time_to_call',
      'total_loss',
      'total_volunteers',
      'unrestrained_animals',
      'work_requested', // This is being shown in its own field
      'zip_code' // This is being shown in the address field
    ]
    var details = [];

    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        if (blackList.indexOf(key) !== -1) { continue; }
        if (!data[key]) { continue; }
        if (data[key] === 'n') { continue; }
        if (data[key] === '0') { continue; }

        var formattedKey = key.replace(/_/g, ' ');
        var formattedValue = data[key].replace(/_/g, ' ');
        formattedKey = formattedKey.charAt(0).toUpperCase() + formattedKey.slice(1);
        formattedValue = formattedValue.charAt(0).toUpperCase() + formattedValue.slice(1);
        details.push(formattedKey + ": " + formattedValue);
      }
    }

    if (details.length > 0) {
      return details.join(', ');
    } else {
      return false;
    }
  }

  /**
   * Creates a table row of two cells created from two DOM nodes
   *
   * @param {HTMLElement} labelNode - the label
   * @param {HTMLElement} valueNode - the value
   *
   * @returns {HTMLElement} row - a tr with two td's
   */
  function createTableRow(labelNode, valueNode) {
    var row = document.createElement('tr');
    var labelCell = document.createElement('td');
    var strongLabel = document.createElement('strong');
    var valueCell = document.createElement('td');
    strongLabel.appendChild(labelNode);
    labelCell.appendChild(strongLabel);
    labelCell.className = 'text-right';
    valueCell.appendChild(valueNode);
    row.appendChild(labelCell);
    row.appendChild(valueCell);

    return row;
  }

  function statusSelect(event) {
    var status = event.target.value;
    $.ajax({
      url: '/api/update-site-status/' + this.site.id,
      type: "POST",
      context: this,
      data: {
        status: status
      },
      dataType: 'json',
      success: function(data) {
        if (data.status === 'success') {
          this.site.claimed_by = data.claimed_by;
          this.site.status = status;
          this.marker.setIcon(generateIconFilename.call(this));
          // TODO: this will all be better in React. I promise.
          toInfoboxHtml.call(this);
        }
      },
      error: function(data) {
        //console.log('error:', data);
      }
    });
  }

  function contactOrg(event) {
    if (this.site.claimed_by) {
      var url = '/worker/incident/' + this.ccmap.event_id + '/organizations/' + this.site.claimed_by;
      var win = window.open(url, '_blank');
      win.focus();
    }
  }

  function print(event) {
    console.log('print:', this);
  }

  function edit(event) {
    $infobox.hide();
    // Just grabbing the simple_form id rendered from the server for now. Kinda jank.
    var $form = document.getElementById('new_legacy_legacy_site');

    // Update the form action to update the site
    $form.action = '/worker/incident/' + this.ccmap.event_id + '/edit/' + this.site.id;

    // Loop over the site attribues and populate the corresponding inputs if they exist
    for (var field in this.site) {
      if (this.site.hasOwnProperty(field) && typeof $form.elements['legacy_legacy_site[' + field + ']'] !== 'undefined') {
        $form.elements['legacy_legacy_site[' + field + ']'].value = this.site[field];
      }
    }

    // Update the form header title
    document.getElementById('form-header').innerHTML = 'Edit Case ' + this.site.case_number;

    this.ccmap.showForm();
  }

  // This should work like a toggle
  function claim(event) {
    $.ajax({
      url: '/api/claim-site/' + this.site.id,
      type: "POST",
      context: this,
      dataType: 'json',
      success: function(data) {
        if (data.status === 'success') {
          // This is kinda gross and asking for trouble. React?
          this.site.claimed_by = data.claimed_by;
          this.site.status = data.site_status;
          this.marker.setIcon(generateIconFilename.call(this));
          // TODO: this will all be better in React. I promise.
          toInfoboxHtml.call(this);
        }
      },
      error: function(data) {
        //console.log('error:', data);
      }
    });
  }
}
