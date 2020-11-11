import Vue from "vue";
import SiteIcon from "./components/dashboard/SiteIcon.vue";
import SiteStatusDropdown from "./components/dashboard/SiteStatusDropdown";
import modal from "./components/modal";

if (document.getElementById("reports-panel")) {
  new Vue({
    el: "#reports-panel",
    propsData: {
      reportTitle: null
    },
    components: {
      modal,
      SiteStatusDropdown,
      SiteIcon
    },
    data: {
      showModal: false,
      reportTitle: null
    },
    methods: {
      fireModal(reportTitle) {
        this.reportTitle = reportTitle;
        this.showModal = true;
      },
      closeModal() {
        this.showModal = false;
        this.$http.post(
          "/report/report/download_alert",
          JSON.stringify({
            report_title: this.reportTitle
          }),
          {
            headers: { "content-type": "application/json" }
          }
        );
      }
    }
  });
}
