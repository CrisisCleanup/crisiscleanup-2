<script>

  let styles = {
    table: {
      tableClass: '',
      loadingClass: 'loader',
      ascendingIcon: 'fi-arrow-up',
      descendingIcon: 'fi-arrow-down',
      handleIcon: 'fi-plus',
      renderIcon: function (classes) {
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
      renderIcon: function (classes) {
        return '<i class="' + classes.join(' ') + '">  </i>';
      }
    }
  };

  import Vue from 'vue';
  import Vuetable from 'vuetable-2/src/components/Vuetable'
  import VuetablePagination from 'vuetable-2/src/components/VuetablePagination'
  import VuetablePaginationInfo from 'vuetable-2/src/components/VuetablePaginationInfo'
  import DatatableEventHub from '../events/DatatableEventHub';
  import FilterBar from './FilterBar';
  import CustomActions from './CustomActions';
  Vue.component('custom-actions', CustomActions);
  Vue.component('filter-bar', FilterBar);

  export default {
    name: 'datatable',
    components: {
      FilterBar,
      Vuetable,
      VuetablePagination,
      VuetablePaginationInfo
    },
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
        default: function () {
          return []
        }
      },
      appendParams: {
        type: Object,
        default: function () {
          return {}
        }
      },
      detailRowComponent: {
        type: String
      }
    },
    mounted: function () {
      var self = this;
      DatatableEventHub.$on('filter-set', function (eventData) {
        return self.onFilterSet(eventData)
      });
      DatatableEventHub.$on('filter-reset', function () {
        return self.onFilterReset()
      });
    },
    render (h) {
      return h(
        'div', {class: {row: true}},
        [
          h('filter-bar', {
            props: {filterPlaceholder: this.filterPlaceholder},
            class: {'small-12': true, 'medium-2': true, 'large-2': true}
          }),
          this.renderVuetable(h),
          this.renderPagination(h)
        ]
      )
    },
    methods: {
      renderVuetable (h) {
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
      renderPagination (h) {
        return h('div', {class: {row: true}}, [
            h('div', {class: {'small-12': true, 'columns': true}}, [
              h(
                'ul',
                {class: {'pagination': true}},
                [
                  h('vuetable-pagination-info', {ref: 'paginationInfo', props: {css: styles.paginationInfo}}),
                  h('vuetable-pagination', {
                    ref: 'pagination',
                    props: {css: styles.pagination},
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
      allcap (value) {
        return value.toUpperCase()
      },
      genderLabel (value) {
        return value === 'M'
          ? '<span class="ui teal label"><i class="large man icon"></i>Male</span>'
          : '<span class="ui pink label"><i class="large woman icon"></i>Female</span>'
      },
      onPaginationData (paginationData) {
        this.$refs.pagination.setPaginationData(paginationData)
        this.$refs.paginationInfo.setPaginationData(paginationData)
      },
      onChangePage (page) {
        this.$refs.vuetable.changePage(page)
      },
      onAction () {
      },
      onCellClicked (data) {
        this.$refs.vuetable.toggleDetailRow(data.id)
      },
      onFilterSet (filterText) {
        this.appendParams.filter = filterText;
        Vue.nextTick(() => { this.$refs.vuetable.refresh() })
      },
      onFilterReset () {
        delete this.appendParams.filter;
        Vue.nextTick( () => this.$refs.vuetable.refresh() );
      }
    }
  }
</script>
