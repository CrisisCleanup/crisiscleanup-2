<template>
    <div @click="onClick">
        <dl>
            <dt>Name:</dt>
            <dd>{{rowData.name}}</dd>
            <dt>Address:</dt>
            <dd>{{rowData.address}}</dd>
            <dt>Phone 1:</dt>
            <dd>{{rowData.phone1}}</dd>
            <dt>Phone 2:</dt>
            <dd>{{rowData.phone2}}</dd>
        </dl>
    </div>
</template>
<script>
  export default {
    name: 'mysites-detail-row',
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