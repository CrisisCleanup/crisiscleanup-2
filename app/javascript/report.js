import Vue from "vue";
import SiteIcon from "./components/dashboard/SiteIcon.vue";
import SiteStatusDropdown from "./components/dashboard/SiteStatusDropdown";
import modal from "./components/modal";

if (document.getElementById("reports-panel")) {
  new Vue({
    el: "#reports-panel",
    propsData: {},
    components: {
      modal,
      SiteStatusDropdown,
      SiteIcon
    },
    data: {
      showModal: false
    },
    methods: {
      fireModal() {
        this.showModal = true;
      },
      closeModal() {
        this.showModal = false;
      }
    }
  });
}
