<template>
  <div class="app-container">

    <el-card v-if="loaded" class="box-card">
      <div slot="header" class="clearfix">
        <span class="account-name">{{ $route.params.username }}</span>
      </div>
      <el-row :gutter="40">
        <el-col :xs="24" :sm="12" :lg="8" class="text item">
          Connected: {{ client.started_at | moment("from", "now") }}
        </el-col>
        <el-col :xs="24" :sm="12" :lg="8" class="item">
          IP Address: {{ client.ip_address }}
        </el-col>
        <el-col :xs="24" :sm="12" :lg="8" class="item">
          Version: {{ client.version }}
        </el-col>
        <el-col :xs="24" :sm="12" :lg="8" class="item">
          Realm: {{ client.selected_realm }}
        </el-col>
        <el-col :xs="24" :sm="12" :lg="8" class="item">
          Selected Character: {{ client.selected_character }}
        </el-col>
        <el-col :xs="24" :sm="12" :lg="8" class="item">
          Status: {{ is_running }}
        </el-col>
      </el-row>
    </el-card>

    <!-- eslint-disable-next-line -->
    <packet-log v-bind:socket="socket" />

  </div>
</template>

<style>
  .account-name {
    font-size: 18pt;
  }

  .item {
    margin-bottom: 18px;
  }

  .clearfix:before,
  .clearfix:after {
    display: table;
    content: "";
  }
  .clearfix:after {
    clear: both
  }
</style>

<script>
import socket from '@/utils/socket'
import request from '@/utils/request'
import PacketLog from '@/views/clients/packet_logs'

export default {
  components: {
    PacketLog
  },

  data() {
    return {
      client: {
      },
      loaded: false,
      socket: socket,
      channel: socket.channel(`clients:${this.$route.params.username}`, {}),
      client_watch_ref: null
    }
  },

  computed: {
    is_running() {
      if (this.client.is_running) {
        return 'Running'
      } else {
        return 'Stopped'
      }
    }
  },

  mounted() {
    this.initClient()
    this.socket.connect()
    this.client_watch_ref = this.channel.on('client_changed', payload => {
      this.client = payload
    })

    this.channel.join()
      .receive('ok', _ => {})
      .receive('error', _ => { console.log('client detail stream not available') })
  },

  beforeDestroy() {
    this.channel.off('client_changed', this.client_watch_ref)
    this.channel.leave()
    this.socket.disconnect()
  },

  methods: {

    initClient() {
      request({ url: `/clients/${this.$route.params.username}` })
        .then(response => {
          this.client = response.data
          this.loaded = true
        }).catch(error => {
          console.log(['Error Loading Client', error])
        })
    }
  }
}

</script>
