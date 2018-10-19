<template>
    <div>
        <div class="row" style="margin: 10px 0px;">
            <div class="small-12 medium-12 large-12 columns">
                <div class="row">
                    <div class="small-12 medium-12 large-12 columns">
                      <label>Incident: </label>
                      <select v-model="selectedIncident">
                        <option v-for="option in incidents" v-bind:value="option.id" :key="option.id">
                          {{ option.name }}
                        </option>
                      </select>
                      <button @click="move" class="button primary medium">Move</button>
                    </div>
                </div>
                <div v-show="showMessage" class="row">
                   <div class="small-12 medium-12 large-12 columns">               
                     <div class="alert-box success radius">
                       <p>{{ actionMessage }}</p>
                     </div>
                   </div>
                </div>
            </div>
        </div>
    </div>
</template>
<script>
  import Raven from 'raven-js';
  
  export default {
    props: [
      'incidents',
      'worksiteId'
    ],
    data() {
      return {
        selectedIncident: {},
        actionMessage: '',
        showMessage: false
      }
    },
    beforeDestroy() {
      this.showMessage = false;
    },
    methods: {
      move: function () {
        let payload = {
          worksiteId: this.worksiteId,
          incidentId: this.selectedIncident
        };
        this.$http.post('/api/move-worksite-to-incident', payload).then(() => {
          const incident = this.incidents.find(x => x.id === this.selectedIncident)
          this.actionMessage = `You have successfully moved the selected worksite to the ${incident.name} incident. Refresh to see the changes.`;
          this.showMessage = true;
          $('#map-infobox').hide();
          setTimeout(() => {
            this.showMessage = false;
          }, 10000);
        }, function (error) {
          this.actionMessage = 'Failed to move worksite to the selected incident.';
          this.showMessage = true;
          setTimeout(() => {
            this.showMessage = false;
          }, 10000);         
          Raven.captureException(error.toString());
        });       
      }
    }
  }
</script>