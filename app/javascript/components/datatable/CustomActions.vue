<template>
    <div class="custom-actions">
        <button class="ui basic button" @click="itemAction('view-item', rowData, rowIndex)"><i class="zoom icon"></i>
        </button>
        <button class="ui basic button" @click="itemAction('edit-item', rowData, rowIndex)"><i class="edit icon"></i>
        </button>
        <button class="ui basic button" @click="itemAction('delete-item', rowData, rowIndex)"><i
                class="delete icon"></i>
        </button>
    </div>
</template>
<script>
  export default {
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
      itemAction (action, data, index) {}
    }
  }
</script>