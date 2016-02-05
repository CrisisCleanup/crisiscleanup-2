var CCMap = CCMap || {};

/**
 * Initializes a map filter object
 * @constructor
 * @param {Object} params - The configuration parameters
 * @param {string} params.id - The id used for DOM elements
 * @param {string} params.label - The visible label show to the user
 * @param {function} params.filterFunction - This is the function applied to the sites to get the subset
 */
CCMap.Filter = function(params) {
  this.id = params.id;
  this.label = params.label;
  this.cached = false;
  this.filteredSitesCache = [];
  this.filterFunction = params.filterFunction;

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
 */
var userOrg = '[organization name]';
CCMap.Filters = function() {
  var filters = [
    { id: "claimed-by", label: "Claimed by " + userOrg },
    { id: "unclaimed", label:  "Unclaimed" },
    { id: "open",  label: "Open" },
    { id: "closed", label: "Closed" },
    { id: "reported-by", label: "Reported by " + userOrg },
    { id: "flood-damage", label: "Primary problem is flood damage" },
    { id: "trees", label: "Primary problem is trees" },
    { id: "debris", label: "Debris removal" },
    { id: "goods-and-services", label: "Primary need is goods and services" }
  ];
  this.filterInputs = [];
  this.activeFilters = [];
  renderFilters.call(this);

  function renderFilters() {
    var filterList = document.getElementById('map-filters');
    filters.forEach(function(filter) {
      var filterObj = new CCMap.Filter({
        id: filter.id,
        label: filter.label,
        filterFunction: function() {
          console.log('TODO');
        }
      });
      // srsly. wtf am i doing here...
      var filterDOM = filterObj.build()
      filterDOM.addEventListener('click', setFilters.bind(this), true);
      filterList.appendChild(filterDOM);
      this.filterInputs.push(filterObj.input);
    }, this);
  }

  function setFilters(event) {
    // Only trigger for the label element
    if (event.target.tagName === 'INPUT') {
      this.activeFilters = this.filterInputs.filter(function(filter) {
        return filter.checked;
      }).map(function(filter) {
        return filter.id;
      });
    }
  }
};
