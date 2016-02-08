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
var userOrg = '[organization name]';
CCMap.Filters = function(params) {
  var onUpdate = params.onUpdate;
  var filterParams = [
    {
      id: "claimed-by",
      label: "Claimed by " + userOrg,
      condition: function() {
        console.log('TODO: claimed-by condition');
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
      id: "reported-by",
      label: "Reported by " + userOrg,
      condition: function() {
        console.log('TODO: reported-by condition');
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
        return site.site.work_type === "Debris removal";
      }
    },
    {
      id: "goods-and-services",
      label: "Primary need is goods and services",
      condition: function(site) {
        return site.site.work_type === "Goods or Services";
      }
    }
  ];
  var filters = [];
  var activeFilters = [];
  renderFilters.call(this);

  function renderFilters() {
    var filterList = document.getElementById('map-filters');
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
      for (var i = 0; i < activeFilters.length; i++) {
        if (activeFilters[i].condition(site)) {
          sites.push(site);
          break;
        }
      };
    });

    return sites;
  }
};
