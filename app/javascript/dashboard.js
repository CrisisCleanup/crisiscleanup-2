
import Vue from 'vue';
import Raven from 'raven-js';
import modal from './components/modal';
import SiteStatusDropdown from './components/dashboard/SiteStatusDropdown';
import SiteIcon from './components/dashboard/SiteIcon.vue';

if (document.getElementById('claimed-worksites')) {
  new Vue({
    el: '#claimed-worksites',
    propsData: {
      siteId: null,
    },
    components: {
      modal,
      SiteStatusDropdown,
      SiteIcon,
    },
    data: {
      showModal: false,
      smsNumbers: '',
    },
    methods: {
      fireModal(siteId) {
        this.siteId = siteId;
        this.showModal = true;
      },
      cancelSend() {
        this.smsNumbers = '';
        this.showModal = false;
      },

      sendMessage() {
        const that = this;
        this.$http.post(
          '/api/messages/send_sms.json',
          JSON.stringify({ type: 'site-info', siteId: this.siteId, numbers: this.smsNumbers }),
          {
            headers: { 'content-type': 'application/json' },
          },
        ).then(function () {
          that.smsNumbers = '';
          this.showModal = false;
        }, (error) => {
          that.hasError = true;
          Raven.captureException(error.toString());
        });
      },
    },
  });
}