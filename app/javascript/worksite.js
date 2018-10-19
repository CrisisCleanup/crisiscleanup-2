import Raven from 'raven-js';
import Vue from 'vue';
import MoveWorksite from './components/worksite/MoveWorksite'

if (document.getElementById("move-worksite-data")) {
  var moveWorksiteVueManager = new Vue({
    el: '#move-worksite-data',
    components: {
      MoveWorksite
    },
    data: {
      incidents: [],
      worksiteId: null,
      loading: false,
      hasError: false
    },
    methods: {
      loadData: function (site) {
        var that = this;
        this.loading = true;
        that.worksiteId = site.id;
        this.$http.get('/api/incidents').then(function (response) {
          that.incidents = response.body.incidents;
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

export default moveWorksiteVueManager;
