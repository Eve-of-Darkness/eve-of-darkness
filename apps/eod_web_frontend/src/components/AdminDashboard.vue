<template>
  <div class="admin-panel">
    <h1>Total Connections: {{ total_connections }}</h1>
    <h1>Total Authenticated: {{ total_authenticated_connections }}</h1>
    <div>
      <div v-for="client in connected_clients" :key="client.account_name">
        <p>{{ client.account_name }}</p>
      </div>
    </div>
  </div>
</template>

<script>

import { Socket } from 'phoenix-socket'
import { HTTP } from '../backend/http'

export default {
  name: 'AdminDashboard',

  mounted () {
    let socket = new Socket('ws://localhost:4000/socket')
    socket.connect()

    this.channel = socket.channel('clients', {})

    this.channel.join()
      .receive('ok', resp => { console.log('Connected Okay') })
      .receive('error', resp => { console.log('No Connect!') })

    this.channel.on('client_count', payload => {
      if (this.total_connections !== payload.total) {
        this.total_connections = payload.total
      }
    })

    this.channel.on('registered_accounts_count', payload => {
      if (this.total_authenticated_connections !== payload.total) {
        this.total_authenticated_connections = payload.total
        HTTP.get(`clients`)
          .then(response => {
            this.connected_clients = response.data.data
          })
          .catch(e => {
            console.log(e)
          })
      }
    })
  },

  data () {
    return {
      total_connections: 0,
      total_authenticated_connections: 0,
      connected_clients: []
    }
  }
}

</script>
