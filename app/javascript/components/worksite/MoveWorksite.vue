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
                      <button v-show="!isVerifying" @click="move(true, false)" class="button primary">{{moveBtnText}}</button>
                      <p v-show="isVerifying">Are you sure you want to move this worksite to the selected incident?</p>
                      <button v-show="isVerifying" @click="move(false, true)" class="button success">Yes</button>
                      <button v-show="isVerifying" @click="move(false, false)" class="button alert">No</button>
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
        selectedIncident: null,
        actionMessage: '',
        showMessage: false,
        moveBtnText: 'Move',
        isVerifying: false,
        isVerified: false
      }
    },
    beforeDestroy() {
      this.showMessage = false;
    },
    methods: {
      resetVerifier: function() {
        this.isVerified = false;
        this.isVerifying = false;
      },
      move: function (isVerifying, isVerified) {
        this.isVerifying = isVerifying;
        this.isVerified = isVerified;
        if (this.isVerified) {
          let payload = {
            worksiteId: this.worksiteId,
            incidentId: this.selectedIncident
          };
          this.$http.post('/api/move-worksite-to-incident', payload).then(() => {
            const incident = this.incidents.find(x => x.id === this.selectedIncident)
            this.actionMessage = `You have successfully moved the selected worksite to the ${incident.name} incident. Refresh to see the changes.`;
            this.showMessage = true;
            $('#map-infobox').hide();
            this.resetVerifier();
            setTimeout(() => {
              this.showMessage = false;
              this.selectedIncident = null;
            }, 5000);
          }, function (error) {
            this.actionMessage = 'Failed to move worksite to the selected incident.';
            this.showMessage = true;
            this.resetVerifier();
            setTimeout(() => {
              this.showMessage = false;
              this.selectedIncident = null;
            }, 5000);         
            Raven.captureException(error);
          });       
        }
      }
    }
  }
</script>