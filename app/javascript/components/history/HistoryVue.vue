<template>
    <div>
        <div class="row">
            <div v-if="claimedByUser" class="small-12 medium-12 large-12 columns">
                <b>Claimed By: </b><a
                    :href="'mailto:' + claimedByUser.u_email">{{claimedByUser.u_name}}</a>
                <br/>
                <b>Organization: </b><a
                    :href="'<%= worker_incident_legacy_organizations_path %>/' + claimedByUser.lg_id">{{claimedByUser.lg_name}}</a>
            </div>
        </div>
        <div class="row" style="margin: 10px 0px;" v-for="user in siteHistory">
            <div class="small-12 medium-12 large-12 columns">
                <div class="row">
                    <div class="small-12 medium-12 large-12 columns">
                        <a :href="'mailto:' + user.user_info.email">{{user.user_info.name}}</a>
                        made {{user.versions.length}} edit<span v-if="user.versions.length > 1">s</span>.
                    </div>
                </div>
                <div class="row" v-for="version in user.versions">
                    <div class="small-11 medium-11 large-11 small-offset-1 medium-offset-1 large-offset-1 columns"
                         style='font-size: smaller;'>
                        <b>*</b>{{getPrettyTimestamp(version.version_info.created_at)}}: {{convertEvent(version.version_info.event)}}
                        <span v-if="version.claimed">- Claimed</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
<script>
  export default {
    props: [
      'siteHistory',
      'claimedByUser'
    ],
    methods: {
      getPrettyTimestamp: function (val) {
        try {
          var d = new Date(val);
          return d.toLocaleString();
        } catch (e) {
          Raven.captureException(e);
        }
      },
      convertEvent: function (val) {
        var newVal = "";
        switch (val) {
          case "create":
            newVal = "Created";
            break;
          case 'update':
            newVal = "Edited";
            break
        }
        return newVal;
      }
    }
  }
</script>