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

  var self = this;
  this.map = params.map;
  this.ccmap = params.ccmap;
  this.site = params.site;
  this.updateInfoboxHtml = toInfoboxHtml.bind(this); // Gross. Calling this in form.js.

  // TODO: check if the file exists on the server or some other validation here.
  this.generateIconFilename = function() {
    var color;
    if (this.site.claimed_by) {
      color = CCMap.UnclaimedStatusColorMap[this.site.status];
    } else {
      color = "red";
    }
    // this is the key sent to the image_path function in app/assets/javascripts/images.js.erb
    return image_path('map_icons/' + this.site.work_type.replace(' ', '_') + '_' + color + '.png');
  }

  this.marker = new google.maps.Marker({
    position: params.position,
    map: params.map,
    icon: self.generateIconFilename.call(self)
  });

  this.marker.addListener("click", function() {
    if (this.ccmap.public_map) {
      toPublicInfoboxHtml.call(this);
    } else {
      toInfoboxHtml.call(this);
    }
    $infobox.slideToggle();
    this.ccmap.showFilters();
  }.bind(this));

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
    var table = document.createElement('div');
    var closeBtn = document.createElement('a');
    closeBtn.className = 'close';
    closeBtn.innerHTML = '&times;';
    var row = document.createElement('div');
    row.className = 'row';
    var header = document.createElement('div');
    header.className = 'small-12 columns';
    closeBtn.addEventListener('click', function() {
      $infobox.slideToggle();
    });
    header.appendChild(closeBtn);
    row.appendChild(header);
    table.appendChild(row);

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

    if (this.site.claimed_by === InitialState.user.org_id || InitialState.user.admin) {
      actionButtons['Unclaim'] = claim.bind(this);
    } else if (this.site.claimed_by === null) {
      actionButtons['Claim'] = claim.bind(this);
    }
    var buttonRow = document.createElement('div');
    buttonRow.className = 'row';
    var buttonCell = document.createElement('div');
    buttonCell.className = 'small-12 medium-9 medium-offset-3 large-10 large-offset-2 columns';
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
    var row = document.createElement('div');
    row.className = 'row';
    var labelCell = document.createElement('div');
    labelCell.className = 'small-12 medium-3 large-2 columns';
    var strongLabel = document.createElement('strong');
    var valueCell = document.createElement('div');
    valueCell.className = 'small-12 medium-9 large-10 columns';
    strongLabel.appendChild(labelNode);
    labelCell.appendChild(strongLabel);
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
          this.marker.setIcon(this.generateIconFilename.call(this));
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
    var url = '/worker/incident/' + this.site.id + '/print';
    var win = window.open(url, '_blank');
    win.focus();
  }

  function edit(event) {
    $infobox.hide();
    var form = new CCMap.Form({
      event_id: this.ccmap.event_id,
      onCancel: function() {
        this.ccmap.showFilters();
        $infobox.show();
      }.bind(this),
      onSave: function() {
        this.ccmap.showFilters();
        $infobox.show();
      }.bind(this)
    });

    form.hydrate(this);

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
          this.site.org_name = data.org_name;
          this.marker.setIcon(this.generateIconFilename.call(this));
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
