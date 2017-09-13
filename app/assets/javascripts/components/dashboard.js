var eventHubDashboard = new Vue(); // Single event hub

Vue.component('modal', {
  template: '#modal-template'
});

Vue.component('site-status-dropdown', {
  template: '#site-status-dropdown',
  props: [
    'siteStatus',
    'siteId'
  ],
  methods: {
    setSiteStatus: function () {
      this.$http.post('/api/update-site-status/' + this.siteId, {status: this.selected}).then(function (response) {
        eventHubDashboard.$emit('site-status-selected', [this.siteId, this.selected]);
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

});

var computeColor = function (status) {
  if (status == 'Closed, completed') {
    return "limegreen";
  } else if (status == 'Open, assigned' || status == 'Open, partially completed' || status == 'Open, needs follow-up') {
    return "#fff000";
  } else if (status.indexOf("Closed") >= 0) {
    return "gray";
  } else {
    return "orange";
  }
}

Vue.component('site-icon', {
  template: '#site-icon',
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
    eventHubDashboard.$on('site-status-selected', function (e) {
      if (e[0] == self.siteId) {
        self.siteColor = computeColor(e[1])
      }
    });
  },
  methods: {
    setSiteStatus: function () {
    }
  }
});

if (document.getElementById("claimed-worksites")) {
  var workerDashboardVue = new Vue({
    el: '#claimed-worksites',
    propsData: {
      siteId: null
    },
    data: {
      showModal: false,
      smsNumbers: ''
    },
    methods: {
      fireModal: function (siteId) {
        this.siteId = siteId;
        this.showModal = true;
      },
      cancelSend: function () {
        this.smsNumbers = '';
        this.showModal = false;
      },

      sendMessage: function () {
        var that = this;
        this.$http.post('/api/messages/send_sms.json',
          JSON.stringify({type: 'site-info', siteId: this.siteId, numbers: this.smsNumbers}),
          {
            headers: {'content-type': 'application/json'}
          }).then(function (response) {
          that.smsNumbers = '';
          this.showModal = false;
        }, function (error) {
          that.hasError = true;
          Raven.captureException(error.toString());
        });
      }
    }
  });
}
