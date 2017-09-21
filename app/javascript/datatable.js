
import Vue from 'vue';
import Datatable from './components/datatable/Datatable';
import LegacySitesDetailRow from './components/datatable/detailrow/LegacySitesDetailRow';
import MysitesDetailRow from './components/datatable/detailrow/MysitesDetailRow';
import UsersDetailRow from './components/datatable/detailrow/UsersDetailRow';
Vue.component('mysites-detail-row', MysitesDetailRow);
Vue.component('users-detail-row', UsersDetailRow);
Vue.component('legacy-sites-detail-row', LegacySitesDetailRow);

document.onreadystatechange = function () {
  if (document.readyState === 'complete') {
    var myworksiteTableVue = document.getElementById("myworksite-table");
    if (typeof(myworksiteTableVue) != 'undefined' && myworksiteTableVue != null) {
      new Vue({
        el: '#myworksite-table',
        components: {
          Datatable
        },
        data () {
          return {

            fields: [
              {
                name: '__handle',
              },
              {
                name: '__sequence',
                title: '#',
              },
              /*
              {
                name: '__checkbox',
              },
              */
              {
                title: "Case Number",
                name: 'case_number',
                sortField: 'case_number',
              },
              {
                title: 'Name',
                name: 'name',
                sortField: 'name',
              },
              {
                title: 'Address',
                name: 'address',
                sortField: 'address',
              },
              {
                title: 'City',
                name: 'city',
                sortField: 'city',
              },
              {
                title: 'County',
                name: 'county',
                sortField: 'county',
              },
              {
                title: 'State',
                name: 'state',
                sortField: 'state',
              },
              {
                title: 'Zip Code',
                name: 'zip_code',
                sortField: 'zip_code',
              },
              {
                name: '__slot:actions',
                title: 'Actions',
              }
            ],
            sortOrder: [
              {
                field: 'case_number',
                sortField: 'case_number',
                direction: 'asc'
              }
            ]
          }
        },
        methods: {
          onAction: function (action, data, index) {
            window.location.href = "/worker/incident/" + data.legacy_event_id + "/edit/" + data.id;
          },
        }
      });
    }

    var usersTableVue = document.getElementById("users-table");
    if (typeof(usersTableVue) != 'undefined' && usersTableVue != null) {
      new Vue({
        el: '#users-table',
        components: {
          Datatable
        },
        data () {
          return {

            fields: [
              {
                name: '__handle',
              },
              {
                name: '__sequence',
                title: '#',
              },
              /*
              {
                name: '__checkbox',
              },
              */
              {
                title: "Email",
                name: 'email',
                sortField: 'email',
              },
              {
                title: 'Name',
                name: 'name',
                sortField: 'name',
              },
              {
                title: 'Organization',
                name: 'lg_name',
                sortField: 'lg_name',
              },
              {
                name: '__slot:actions',
                title: 'Actions',
              }
            ],
            sortOrder: [
              {
                field: 'name',
                sortField: 'name',
                direction: 'asc'
              }
            ]
          }
        },
        methods: {
          onAction: function (action, data, index) {
            window.location.href = "/admin/users/" + data.id + "/edit";
          },
        }
      });
    }
  }
};
