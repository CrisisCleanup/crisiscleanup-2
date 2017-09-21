<template>
    <div class="row collapse">
        <div class="small-12 medium-6 large-6">
            <input type="text" v-model="filterText" @keyup.enter="doFilter" :placeholder="filterPlaceholder">
        </div>
        <div class="small-12 medium-4 large-4 columns">
            <ul class="stack button-group radius">
                <li><a href="#" class="button tiny" @click="doFilter">Go</a></li>
                <li><a href="#" class="button info tiny" @click="resetFilter">Reset</a></li>
            </ul>
        </div>
    </div>
</template>
<script>
  import DatatableEventHub from '../events/DatatableEventHub';

  export default {
    props: [
      'filterPlaceholder'
    ],
    data: function () {
      return {
        filterText: ''
      }
    },
    methods: {
      doFilter: function () {
        DatatableEventHub.$emit('filter-set', this.filterText);
      },
      resetFilter: function () {
        this.filterText = '';
        DatatableEventHub.$emit('filter-reset');
      }
    }
  }
</script>