import Raven from 'raven-js';
import Vue from 'vue';
import HistoryVue from './components/history/HistoryVue'

Vue.filter('phone', function (phone) {
  return phone.replace(/[^0-9]/g, '')
    .replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
});

if (document.getElementById("history-data")) {
  var historyVueManager = new Vue({
    el: '#history-data',
    components: {
      HistoryVue
    },
    data: {
      historyData: {},
      claimedByUser: "",
      loading: false,
      hasError: false
    },
    methods: {
      loadHistoryData: function (site) {
        var that = this;
        this.loading = true;
        this.$http.get('/api/site-history/' + site.id).then(function (response) {
          that.historyData = response.body.history;
          that.claimedByUser = response.body.claimed_by_user;
          that.loading = false;
        }, function (error) {
          that.loading = false;
          that.hasError = true;
          Raven.captureException(error.toString());
        });
      }
    }
  });
}

export default historyVueManager;
