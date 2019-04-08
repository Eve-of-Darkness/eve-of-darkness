<template>
  <div class="admin-panel">
    <h1>Total Connections: {{ total_connections }}</h1>
  </div>
</template>

<script>

import { Socket } from 'phoenix-socket'

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
      this.total_connections = payload.total
    })
  },

  data () {
    return {
      total_connections: 0
    }
  }
}

</script>
