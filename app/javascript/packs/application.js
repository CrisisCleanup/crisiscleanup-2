/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue';
import VueResource from 'vue-resource';
import Raven from 'raven-js';
import RavenVue from 'raven-js/plugins/vue';
Raven.config('https://10c81ccdb4ca40d39a1fafa02154e6c7@sentry.io/212434').addPlugin(RavenVue, Vue).install();

Vue.use(VueResource);

import 'dashboard'
import 'history'
import 'datatable'
import 'worksite'
import 'worksite_pin'

// Map
import 'legacy/models/cluster'
import 'legacy/models'
import 'legacy/models/scripts'

// Other
import 'legacy/other/incident_chooser';
import 'legacy/other/invitation_form';
import 'legacy/other/registration_form';
import 'legacy/other/organization_contacts';

// Admin
import 'legacy/admin/form';
import 'legacy/admin/legacy_organization_form';

// Static
import 'legacy/static_pages/index';
import 'legacy/static_pages/public_map';

import 'call'