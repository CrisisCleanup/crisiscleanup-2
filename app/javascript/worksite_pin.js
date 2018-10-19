import Vue from 'vue';
import MoveWorksitePin from './components/worksite/MoveWorksitePin'

if (document.getElementById("wrong-location-data")) {
  var wrongLocationVueManager = new Vue({
    el: '#wrong-location-data',
    components: {
      MoveWorksitePin
    },
    data: {
      worksiteId: null,
      loading: false,
      hasError: false
    },
    methods: {
      loadData: function (site) {
        var that = this;
        that.worksiteId = site.id;
      }      
    }
  });
}

export default wrongLocationVueManager;
