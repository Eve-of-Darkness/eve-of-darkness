<template>
  <div class="app-container">
    <el-form ref="form" :model="form" label-width="120px">
      <el-form-item label="Account Name">
        <el-input v-model="form.name" />
      </el-form-item>
    </el-form>

    <el-table
      v-loading="clients_loading"
      :data="clients"
      element-loading-text="Loading"
      border
      fit
      highlight-current-row
    >
      <el-table-column align="center" label="Account Name" width="195">
        <template slot-scope="scope">
          {{ scope.row.account_name }}
        </template>
      </el-table-column>

      <el-table-column align="right" label="IP Address" width="150">
        <template slot-scope="scope">
          {{ scope.row.ip_address }}
        </template>
      </el-table-column>

      <el-table-column align="right" label="Start Time">
        <template slot-scope="scope">
          {{ scope.row.started_at | moment("from", "now") }}
        </template>
      </el-table-column>

      <el-table-column align="center" label="Options">
        <template slot-scope="scope">
          <el-button type="primary" @click="$router.push(`/clients/${scope.row.account_name}`)">Inspect</el-button>
        </template>
      </el-table-column>

    </el-table>
  </div>
</template>

<script>
import socket from '@/utils/socket'
import request from '@/utils/request'

export default {

  data() {
    return {
      form: {
        name: ''
      },
      socket: socket,
      channel: socket.channel('clients', {}),
      channel_change_ref: null,
      clients: [],
      clients_loading: false
    }
  },

  mounted() {
    this.loadClients()

    this.socket.connect()
    this.channel_change_ref = this.channel.on('registered_accounts_count', payload => {
      this.loadClients()
    })

    this.channel.join()
      .receive('error', resp => { console.log('unable to connect to clients channel') })
  },

  beforeDestroy() {
    this.channel.off('registered_accounts_count', this.channel_change_ref)
    this.socket.disconnect()
  },

  methods: {
    loadClients() {
      this.clients_loading = true
      request({ url: '/clients' }).then(response => {
        this.clients = response.data
        this.clients_loading = false
      }).catch(error => {
        console.log(['Error Loding Clients', error])
      })
    }
  }
}
</script>

<style scoped>
.line{
  text-align: center;
}
</style>
