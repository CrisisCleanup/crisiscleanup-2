var CCMap = CCMap || {};

/**
 * Initializes a map filter object
 * @constructor
 * @param {Object} params - The configuration parameters
 * @param {string} params.id - The id used for DOM elements
 * @param {string} params.label - The visible label show to the user
 * @param {function} params.condition - Test site must pass to be in this set
 */
CCMap.Filter = function(params) {
  this.id = params.id;
  this.label = params.label;
  this.condition = params.condition;

  this.build = function() {
    this.input = document.createElement('input');
    this.input.setAttribute('id', this.id);
    this.input.setAttribute('type', 'checkbox');
    var label = document.createElement('label');
    label.setAttribute('for', this.id);
    label.appendChild(document.createTextNode(this.label));
    var listItem = document.createElement('li');
    listItem.appendChild(this.input);
    listItem.appendChild(label);

    return listItem;
  }.bind(this);
}

/**
 * Build all of the CCMap.Map filters here
 * @constructor
 * @param {Object} params - The configuration parameters
 * @param {function} params.onUpdate - The function called when filters update
 */
CCMap.Filters = function(params) {
  var userOrgId;
  var userOrgName;
  var userAdmin;
  // TODO: Update this mess once we get lodash in here.
  if (InitialState) {
    userOrgId = InitialState.user.org_id;
    userOrgName = InitialState.user.org_name;
    userAdmin = InitialState.user.admin;
  }
  var onUpdate = params.onUpdate;
  var filterParams = [
    {
      id: "claimed-by",
      label: "Claimed by " + userOrgName,
      condition: function(site) {
        return site.site.claimed_by === userOrgId;
      }
    },
    {
      id: "reported-by",
      label: "Reported by " + userOrgName,
      condition: function(site) {
        return site.site.reported_by === userOrgId;
      }
    },
    {
      id: "unclaimed",
      label:  "Unclaimed",
      condition: function(site) {
        return site.site.claimed_by === null;
      }
    },
    {
      id: "open",
      label: "Open",
      condition: function(site) {
        return /Open/.test(site.site.status)
      }
    },
    {
      id: "closed",
      label: "Closed",
      condition: function(site) {
        return /Closed/.test(site.site.status)
      }
    },
    {
      id: "flood-damage",
      label: "Primary problem is flood damage",
      condition: function(site) {
        return site.site.work_type === "Flood";
      }
    },
    {
      id: "trees",
      label: "Primary problem is trees",
      condition: function(site) {
        return site.site.work_type === "Trees";
      }
    },
    {
      id: "debris",
      label: "Debris removal",
      condition: function(site) {
        return /Debris/.test(site.site.work_type);
      }
    },
    {
      id: "other",
      label: "Other",
      condition: function(site) {
        return /^(?!Debris|Trees|Flood).*$/.test(site.site.work_type);
      }
    }
  ];
  var filters = [];
  var activeFilters = [];
  var filterList = document.getElementById('map-filters');
  if (filterList) {
    renderFilters.call(this);
  }

  function renderFilters() {
    filterParams.forEach(function(filter) {
      var filterObj = new CCMap.Filter(filter);
      var filterDOM = filterObj.build()
      filterDOM.addEventListener('click', setFilters.bind(this), true);
      filterList.appendChild(filterDOM);
      filters.push(filterObj);
    }, this);
  }

  function setFilters(event) {
    // Only trigger for the input element
    if (event.target.tagName === 'INPUT') {
      activeFilters = filters.filter(function(filter) {
        return filter.input.checked;
      }).map(function(filter) {
        return filter;
      });
      onUpdate();
    }
  }

  this.getFilteredSites = function(allSites) {
    if (activeFilters.length === 0) {
      return allSites;
    }

    var sites = [];

    allSites.forEach(function(site) {
      // General ORs for all active filtes. This should probably be refined.
      var passes = true;
      for (var i = 0; i < activeFilters.length; i++) {
        if (!activeFilters[i].condition(site)) {
          passes = false;
          break;
        }
      };

      if (passes) {
        sites.push(site);
      }
    });

    return sites;
  }
};
