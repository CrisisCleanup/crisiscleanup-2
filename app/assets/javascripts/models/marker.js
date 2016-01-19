var CCMap = CCMap || {};

// build map with all of the pins clustered
CCMap.IconDir = '/assets/map_icons/';
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
  this.map = params.map;
  this.site = params.site;
  this.marker = new google.maps.Marker({
    position: params.position,
    map: params.map,
    icon: generateIconFilename.call(this)
  });
  this.marker.addListener("click", toggleInfobox.bind(this));

  // TODO: check if the file exists on the server or some other validation here.
  function generateIconFilename() {
    var color;
    if (this.site.claimed_by) {
      color = CCMap.UnclaimedStatusColorMap[this.site.status];
    } else {
      color = "red";
    }
    return CCMap.IconDir + this.site.work_type + '_' + color + '.png';
  }

  function toggleInfobox() {
    // TODO: set the map container to a property on this
    var $infobox = $('#map-infobox');
    $infobox.html(toInfoboxHtml.call(this));
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
      "Phone": this.site.phone,
      "Phone": "[alternate number]",
      "Details": "[...]"
    };

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
      option.appendChild(document.createTextNode(optionLabel));
      statusDropdown.appendChild(option);
    });
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
          document.createTextNode(this.site.claimed_by)
        )
      );
    }

    // action buttons
    // TODO: a button class would be cool here, so we could attach the click event callbacks and whatnot.
    var actionButtons = {
      "Contact Organization": contactOrg.bind(this),
      "Printer Friendly": print.bind(this),
      "Edit": edit.bind(this),
      "Unclaim": unclaim.bind(this)
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

    return table;
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
    console.log('status update:', event.target.value);
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

  function unclaim(event) {
    console.log('unclaim:', this);
  }
}
