<template>
    <i class="fa fa-home fa-2x" v-bind:style="{color: siteColor}"></i>
</template>
<script>
  let computeColor = function (status) {
    if (status == 'Closed, completed') {
      return "limegreen";
    } else if (status == 'Open, assigned' || status == 'Open, partially completed' || status == 'Open, needs follow-up') {
      return "#fff000";
    } else if (status.indexOf("Closed") >= 0) {
      return "gray";
    } else {
      return "orange";
    }
  };

  import DashboardEventHub from '../events/DashboardEventHub'

  export default {
    name: 'site-icon',
    props: [
      'siteStatus',
      'siteId'
    ],
    data: function () {
      return {
        siteColor: computeColor(this.siteStatus)
      }
    },
    mounted: function () {
      var self = this;
      DashboardEventHub.$on('site-status-selected', function (e) {
        if (e[0] == self.siteId) {
          self.siteColor = computeColor(e[1])
        }
      });
    },
    methods: {
      setSiteStatus: function () {
      }
    }
  }
</script>