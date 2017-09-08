var eventHub = new Vue(); // Single event hub

// Distribute to components using global mixin
Vue.mixin({
  data: function () {
    return {
      eventHub: eventHub
    }
  }
});

Vue.component('filter-bar', {
  template: '#filter-bar-template',
  props: [
    'filterPlaceholder'
  ],
  data: function() {
    return {
      filterText: ''
    }
  },
  methods: {
    doFilter: function () {
      this.eventHub.$emit('filter-set', this.filterText);
    },
    resetFilter: function () {
      this.filterText = '';
      this.eventHub.$emit('filter-reset');
    }
  }
});

Vue.component('detail-row', {
  template: '#detail-row-template',
  props: {
    rowData: {
      type: Object,
      required: true
    },
    rowIndex: {
      type: Number
    }
  },
  methods: {
    onClick: function(event) {
      console.log('my-detail-row: on-click', event.target)
    }
  }
});

Vue.component('custom-actions', {
  template: '#custom-actions-template',
  props: {
    rowData: {
      type: Object,
      required: true
    },
    rowIndex: {
      type: Number
    }
  },
  methods: {
    itemAction: function (action, data, index) {
      console.log('custom-actions: ' + action, data.name, index)
    }
  }
});

var styles = {
  table: {
    tableClass: '',
    loadingClass: 'loader',
    ascendingIcon: 'fi-arrow-up',
    descendingIcon: 'fi-arrow-down',
    handleIcon: 'fi-plus',
    renderIcon: function(classes, options) {
      return ' <i class="' + classes.join(' ') + '">  </i> ';
    }
  },
  pagination: {
    wrapperClass: "",
    activeClass: "btn-primary",
    disabledClass: "disabled",
    pageClass: "btn btn-border",
    linkClass: "btn btn-border",
    icons: {
      first: "",
      prev: "fi-arrow-left",
      next: "fi-arrow-right",
      last: ""
    },
    renderIcon: function(classes, options) {
      return '<i class="' + classes.join(' ') + '">  </i>';
    }
  }
}

var myViewTable = Vue.component('my-view-table', {
  name: 'my-view-table',
  // template: '#my-viewtable-template',
  props: {
    apiUrl: {
      type: String,
      required: true
    },
    filterPlaceholder: {
      type: String,
      required: true
    },
    fields: {
      type: Array,
      required: true
    },
    sortOrder: {
      type: Array,
      default: function() {
        return []
      }
    },
    appendParams: {
      type: Object,
      default: function() {
        return {}
      }
    },
    detailRowComponent: {
      type: String
    }
  },
  mounted: function () {
    var self = this;
    this.eventHub.$on('filter-set', function (eventData) { return self.onFilterSet(eventData)});
    this.eventHub.$on('filter-reset', function(e) { return self.onFilterReset()});
  },
  render: function(h) {
    var self = this;
    return h(
      'div', {class: { row: true }},
      [
           h('filter-bar', {props: {filterPlaceholder: this.filterPlaceholder}, class: { 'small-12': true, 'medium-2': true, 'large-2': true}}),
          this.renderVuetable(h),
          this.renderPagination(h)
      ]
    )
  },
  methods: {
    renderVuetable: function(h) {
      return h('div', {class: {row: true}}, [
          h(
            'vuetable',
            {
              ref: 'vuetable',
              props: {
                apiUrl: this.apiUrl,
                fields: this.fields,
                paginationPath: "",
                perPage: 10,
                multiSort: true,
                sortOrder: this.sortOrder,
                appendParams: this.appendParams,
                detailRowComponent: this.detailRowComponent,
                css: styles.table
              },
              on: {
                'vuetable:cell-clicked': this.onCellClicked,
                'vuetable:pagination-data': this.onPaginationData,
              },
              scopedSlots: this.$vnode.data.scopedSlots
            }
          )
      ])
    },
    renderPagination: function(h) {
      return h('div', {class: {row: true}}, [
        h('div', {class: {'small-12': true, 'columns': true}}, [
          h(
            'ul',
            {class: {'pagination': true}},
            [
              h('vuetable-pagination-info', {ref: 'paginationInfo', props: { css: styles.paginationInfo }}),
              h('vuetable-pagination', {
                ref: 'pagination',
                props: { css: styles.pagination },
                on: {
                  'vuetable-pagination:change-page': this.onChangePage
                }
              })
            ]
          )
          ])
        ]
      )
    },
    allcap: function (value) {
      return value.toUpperCase()
    },
    genderLabel: function (value) {
      return value === 'M'
        ? '<span class="ui teal label"><i class="large man icon"></i>Male</span>'
        : '<span class="ui pink label"><i class="large woman icon"></i>Female</span>'
    },
    formatNumber: function (value) {
      return accounting.formatNumber(value, 2)
    },
    /*
    formatDate: function (value, fmt) {
      return (value == null)
        ? ''
        : moment(value, 'YYYY-MM-DD').format(fmt)
    },
    */
    onPaginationData: function (paginationData) {
      this.$refs.pagination.setPaginationData(paginationData)
      this.$refs.paginationInfo.setPaginationData(paginationData)
    },
    onChangePage: function (page) {
      this.$refs.vuetable.changePage(page)
    },
    onAction: function (action, data, index) {
      console.log('slot action: ' + action, data.name, index)
    },
    onCellClicked: function (data, field, event) {
      console.log('cellClicked: ', field.name)
      this.$refs.vuetable.toggleDetailRow(data.id)
    },
    onFilterSet: function (filterText) {
      var self = this;
      this.appendParams.filter = filterText
      Vue.nextTick(function () {
        self.$refs.vuetable.refresh()
      })
    },
    onFilterReset: function () {
      var self = this;
      delete this.appendParams.filter
      Vue.nextTick(function () {
        self.$refs.vuetable.refresh()
      })
    }
  }

});

document.onreadystatechange = function () {
  if (document.readyState === 'complete') {
  var myworksiteTableVue = document.getElementById("myworksite-table");
  if (typeof(myworksiteTableVue) != 'undefined' && myworksiteTableVue != null) {
    new Vue({
      el: '#myworksite-table',
      data: function () {
        return {

          fields: [
            {
              name: '__handle',
            },
            {
              name: '__sequence',
              title: '#',
            },
            /*
            {
              name: '__checkbox',
            },
            */
            {
              title: "Case Number",
              name: 'case_number',
              sortField: 'case_number',
            },
            {
              title: 'Name',
              name: 'name',
              sortField: 'name',
            },
            {
              title: 'Address',
              name: 'address',
              sortField: 'address',
            },
            {
              title: 'City',
              name: 'city',
              sortField: 'city',
            },
            {
              title: 'County',
              name: 'county',
              sortField: 'county',
            },
            {
              title: 'State',
              name: 'state',
              sortField: 'state',
            },
            {
              title: 'Zip Code',
              name: 'zip_code',
              sortField: 'zip_code',
            },
            {
              name: '__slot:actions',
              title: 'Actions',
            }
          ],
          sortOrder: [
            {
              field: 'case_number',
              sortField: 'case_number',
              direction: 'asc'
            }
          ]
        }
      },
      methods: {
        onAction: function (action, data, index) {
          window.location.href = "/worker/incident/" + data.legacy_event_id + "/edit/" + data.id;
        },
      }
    });
  }

    var usersTableVue = document.getElementById("users-table");
    if (typeof(usersTableVue) != 'undefined' && usersTableVue != null) {
      new Vue({
        el: '#users-table',
        components: {
          "my-view-table": myViewTable
        },
        data: function () {
          return {

            fields: [
              {
                name: '__handle',
              },
              {
                name: '__sequence',
                title: '#',
              },
              /*
              {
                name: '__checkbox',
              },
              */
              {
                title: "Email",
                name: 'email',
                sortField: 'email',
              },
              {
                title: 'Name',
                name: 'name',
                sortField: 'name',
              },
              {
                title: 'Organization',
                name: 'lg_name',
                sortField: 'lg_name',
              },
              {
                name: '__slot:actions',
                title: 'Actions',
              }
            ],
            sortOrder: [
              {
                field: 'name',
                sortField: 'name',
                direction: 'asc'
              }
            ]
          }
        },
        methods: {
          onAction: function (action, data, index) {
            window.location.href = "/admin/users/" + data.id + "/edit";
          },
        }
      });
    }
  }
};
