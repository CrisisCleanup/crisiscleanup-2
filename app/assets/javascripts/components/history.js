Vue.filter('phone', function (phone) {
  return phone.replace(/[^0-9]/g, '')
    .replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
});

Vue.component('history-vue', {
  template: "#history-template",
  props: [
    'siteHistory',
    'claimedByUser'
  ],
  methods: {
    getPrettyTimestamp: function (val) {
      try {
        var d = new Date(val);
        return d.toLocaleString();
      } catch(e) {
        Raven.captureException(e);
      }
    },
    convertEvent: function (val) {
      var newVal = "";
      switch (val) {
        case "create":
          newVal = "Created";
          break;
        case 'update':
          newVal = "Edited";
          break
      }
      return newVal;
    }
  }
});


if (document.getElementById("history-data")) {
  var historyVue = new Vue({
    el: '#history-data',
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
