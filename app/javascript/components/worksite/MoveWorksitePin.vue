<template>
    <div>
        <div class="row" style="margin: 10px 0px;">
            <div class="small-12 medium-12 large-12 columns">
                <div class="row">
                    <div class="small-12 medium-12 large-12 columns">
                      <label>Google Map URL: </label>
                      <textarea v-model="pinUrl" placeholder="Google Map URL" rows="6"></textarea>
                      <button @click="parseUrl" class="button primary">Change Pin Location</button>
                    </div>
                </div>
                <div v-show="showMessage" class="row">
                   <div class="small-12 medium-12 large-12 columns">               
                     <div v-bind:class="alertBoxStyle">
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
      'worksiteId'
    ],
    data() {
      return {
        pinUrl: '',
        selectedIncident: {},
        actionMessage: '',
        showMessage: false,
        alertBoxStyle: {
          'alert-box': true,
          'radius': true,
          'success': false,
          'alert': false
        }
      }
    },
    beforeDestroy() {
      this.showMessage = false;
    },
    methods: {
      setAlertStyle(success, warning, alertStyle) {
        this.alertBoxStyle.success = success;
        this.alertBoxStyle.warning = warning;           
        this.alertBoxStyle.alert = alertStyle;
      },
      parseUrl() {
        let coordinates = null;
        
        try {
          let uri = new URL(this.pinUrl);
          let splitUri = uri.pathname.match(/@.+z/g);
          coordinates = splitUri[0].split(',');
        } catch (error) {
          this.actionMessage = "ERROR: \n Could not parse given pin URL."
          this.setAlertStyle(false, false, true);
          this.showMessage = true;           
          setTimeout(() => {
            this.showMessage = false;           
          }, 10000);         
          Raven.captureException(error.toString());
        }
        
        const latitude = parseFloat(coordinates[0].replace('@', ''));
        const longitude = parseFloat(coordinates[1]);
        const zoomLevel = parseFloat(coordinates[2].replace('z', ''));       
        
        if (zoomLevel < 20) {
          this.actionMessage = "ERROR: \nThe map link provided was not zoomed-in close enough when captured. Please zoom in as far as you can, re-copy the link, and paste again."
          this.setAlertStyle(false, true, false);
          this.showMessage = true;           
          setTimeout(() => {
            this.showMessage = false;           
          }, 10000);
        } else {
          const payload = {
            worksiteId: this.worksiteId,
            latitude: latitude,
            longitude: longitude,
            zoomLevel: zoomLevel
          }
          this.$http.post('/api/relocate-worksite-pin', payload).then(() => {
            this.actionMessage = `You have successfully relocated the worksite's pin.`;
            this.setAlertStyle(false, true, false);
            this.showMessage = true;
            $('#map-infobox').hide();
            setTimeout(() => {
              this.showMessage = false;
            }, 10000);
          }, function (error) {
            this.actionMessage = 'Failed to move worksite to the selected incident.';
            this.showMessage = true;
            this.setAlertStyle(false, false, true);
            setTimeout(() => {
              this.showMessage = false;
            }, 10000);         
            Raven.captureException(error.toString());
          }); 
        }
      }
    }
  }
</script>