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
      currentIncidentId: null,
      worksiteId: null,
      loading: false,
      hasError: false
    },
    methods: {
      loadData: function (site) {
        this.loading = true;
        this.worksiteId = site.id;
        this.currentIncidentId = site.legacy_event_id;
        this.$http.get('/api/incidents').then((response) => {
          let incidents = response.body.incidents;
          incidents.splice(incidents.findIndex((i) => {
              return i.id === this.currentIncidentId;
          }), 1);
          this.incidents = incidents;
          this.loading = false;
        }, (error) => {
          this.loading = false;
          this.hasError = true;
          Raven.captureException(error.toString());
        });
      }      
    }
  });
}

export default moveWorksiteVueManager;
