<template>
  <el-row :gutter="40" class="panel-group">
    <el-col :xs="24" :sm="12" :lg="8" class="card-panel-col">
      <div class="card-panel">
        <div class="card-panel-icon-wrapper icon-people">
          <svg-icon icon-class="network-connections" class-name="card-panel-icon" />
        </div>
        <div class="card-panel-description">
          <div class="card-panel-text">
            Connections
          </div>
          <div class="card-panel-num">{{ total_connections }}</div>
        </div>
      </div>
    </el-col>
    <el-col :xs="24" :sm="12" :lg="8" class="card-panel-col">
      <div class="card-panel">
        <div class="card-panel-icon-wrapper icon-message">
          <svg-icon icon-class="peoples" class-name="card-panel-icon" />
        </div>
        <div class="card-panel-description">
          <div class="card-panel-text">
            Authenticated
          </div>
          <div class="card-panel-num">{{ total_authenticated_connections }}</div>
        </div>
      </div>
    </el-col>
  </el-row>
</template>

<script>
import socket from '@/utils/socket'

export default {
  name: 'OverviewPanel',

  data() {
    return {
      total_connections: 0,
      total_authenticated_connections: 0,
      socket: socket,
      channel: socket.channel('clients', {}),
      client_count_ref: null,
      registered_accounts_ref: null
    }
  },

  mounted() {
    this.socket.connect()

    this.client_count_ref = this.channel.on('client_count', payload => {
      if (this.total_connections !== payload.total) {
        this.total_connections = payload.total
      }
    })

    this.registered_accounts_ref = this.channel.on('registered_accounts_count', payload => {
      if (this.total_authenticated_connections !== payload.total) {
        this.total_authenticated_connections = payload.total
      }
    })

    this.channel.join()
      .receive('ok', resp => { console.log('connected to clients channel') })
      .receive('error', resp => { console.log('unable to connect to clients channel') })
  },

  beforeDestroy() {
    this.channel.off('client_count', this.client_count_ref)
    this.channel.off('registered_accounts_count', this.registered_accounts_ref)
    this.socket.disconnect()
  }
}
</script>

<style lang="scss" scoped>
.panel-group {
  margin-top: 18px;
  .card-panel-col{
    margin-bottom: 32px;
  }
  .card-panel {
    height: 108px;
    cursor: pointer;
    font-size: 12px;
    position: relative;
    overflow: hidden;
    color: #666;
    background: #fff;
    box-shadow: 4px 4px 40px rgba(0, 0, 0, .05);
    border-color: rgba(0, 0, 0, .05);
    &:hover {
      .card-panel-icon-wrapper {
        color: #fff;
      }
      .icon-people {
         background: #40c9c6;
      }
      .icon-message {
        background: #36a3f7;
      }
      .icon-money {
        background: #f4516c;
      }
      .icon-shopping {
        background: #34bfa3
      }
    }
    .icon-people {
      color: #40c9c6;
    }
    .icon-message {
      color: #36a3f7;
    }
    .icon-money {
      color: #f4516c;
    }
    .icon-shopping {
      color: #34bfa3
    }
    .card-panel-icon-wrapper {
      float: left;
      margin: 14px 0 0 14px;
      padding: 16px;
      transition: all 0.38s ease-out;
      border-radius: 6px;
    }
    .card-panel-icon {
      float: left;
      font-size: 48px;
    }
    .card-panel-description {
      float: right;
      font-weight: bold;
      margin: 26px;
      margin-left: 0px;
      .card-panel-text {
        line-height: 18px;
        color: rgba(0, 0, 0, 0.45);
        font-size: 16px;
        margin-bottom: 12px;
      }
      .card-panel-num {
        font-size: 20px;
      }
    }
  }
}
</style>
