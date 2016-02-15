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
  this.site = params.site;
  this.marker = new google.maps.Marker({
    position: params.position,
    map: params.map,
    icon: generateIconFilename.call(this)
  });
  this.marker.addListener("click", function() {
    toInfoboxHtml.call(this);
    $infobox.show();
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
   */
  function toInfoboxHtml() {
    var table = document.createElement('table');

    // Create an object of key value pairs to display
    var displayObj = {
      "Case Number": this.site.case_number,
      "Name": this.site.name,
      "Requests": this.site.work_type,
      "Address": this.site.address + ", " + this.site.city + ", " + this.site.state,
      "Phone": "[alternate number]",
      "Details": this.site.data
    };
    console.log(this.site.data);

    // Test for zip_code. I don't see any zip codes in the current data
    if (this.site.zip_code) {
      displayObj["Address"] += "  " + this.site.zip_code;
    }

    // data hstore field stuff


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
    var actionButtons = {
      "Contact Organization": contactOrg.bind(this),
      "Printer Friendly": print.bind(this),
      "Edit": edit.bind(this)
    }
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
    console.log('contact org:', this);
  }

  function print(event) {
    console.log('print:', this);
  }

  function edit(event) {
    console.log('edit:', this);
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
