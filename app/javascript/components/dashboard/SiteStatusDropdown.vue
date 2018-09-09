<template>
    <div class="row collapse" style="margin-bottom:0;">
        <div class="small-12 small-centered medium-12 medium-centered large-6 large-centered columns"
             style="margin-bottom:0;">
            <select v-model="selected" @change="setSiteStatus()">
                <option disabled value="">Please select one</option>
                <option>Open, unassigned</option>
                <option>Open, assigned</option>
                <option>Open, partially completed</option>
                <option>Open, needs follow-up</option>
                <option>Closed, completed</option>
                <option>Closed, incomplete</option>
                <option>Closed, out of scope</option>
                <option>Closed, done by others</option>
                <option>Closed, no help wanted</option>
                <option>Closed, rejected</option>
                <option>Closed, duplicate</option>
            </select>
        </div>
    </div>
</template>
<script>
  import DashboardEventHub from '../events/DashboardEventHub'
  import Raven from 'raven-js'
  export default {
    name: 'site-status-dropdown',
    props: [
      'siteStatus',
      'siteId'
    ],
    methods: {
      setSiteStatus: function () {
        this.$http.post('/api/update-site-status/' + this.siteId, {status: this.selected}).then(function () {
          DashboardEventHub.$emit('site-status-selected', [this.siteId, this.selected]);
        }, function (error) {
          Raven.captureException(error.toString());
        });
      }
    },
    data: function () {
      return {
        selected: this.siteStatus
      }
    }
  }
</script>