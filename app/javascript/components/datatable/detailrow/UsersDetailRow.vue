<template>
    <div @click="onClick">
        <dl>
            <dt>ID:</dt>
            <dd>{{rowData.id}}</dd>
            <dt>Role:</dt>
            <dd>{{rowData.role}}</dd>
            <dt>Title:</dt>
            <dd>{{rowData.title}}</dd>
            <dt>Mobile:</dt>
            <dd>{{rowData.mobile}}</dd>
            <dt>Admin:</dt>
            <dd>{{rowData.admin}}</dd>
            <dt>Accept Terms:</dt>
            <dd>{{rowData.accepted_terms}}</dd>
            <dt>Accept Terms Timestamp:</dt>
            <dd>{{rowData.accepted_terms_timestamp}}</dd>
        </dl>
    </div>
</template>
<script>
  export default {
    name: 'users-detail-row',
    props: {
      rowData: {
        type: Object,
        required: true
      },
      rowIndex: {
        type: Number
      }
    },
    methods: {
      onClick: function (event) {
      }
    }
  }
</script>