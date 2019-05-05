<template>
  <div class="packet-log">
    <sticky :z-index="10" :sticky-top="50">
      <el-card>
        <el-button type="primary" @click="watchNetwork">Watch Network</el-button>
        <el-switch v-model="follow_logs" active-text="Follow Logs" />
      </el-card>
    </sticky>
    <pre class="log-output">
      {{ packet_display }}
    </pre>
  </div>
</template>

<script>
import socket from '@/utils/socket'
import Sticky from '@/components/Sticky'

export default {
  name: 'PacketLog',
  components: { Sticky },

  props: {
    socket: {
      type: Object,
      default: () => { socket }
    }
  },

  data() {
    return {
      packets: [],
      follow_logs: true,
      tail_timer: null,
      network_watch_ref: null,
      watching_network: false,
      channel: this.socket.channel(`clients-packets:${this.$route.params.username}`, {})
    }
  },

  computed: {
    packet_display() {
      return this.packets.map(p => { return p.data }).join('\n\n')
    }
  },

  watch: {
    packets() {
      if (this.tail_timer !== null) {
        clearTimeout(this.tail_timer)
      }
      this.tail_timer = setTimeout(this.scroll_to_end, 250)
    }
  },

  beforeDestroy() {
    if (this.network_watch_ref !== null) {
      this.channel.off('packet_traffic', this.network_watch_ref)
    }
    this.channel.leave()
  },

  methods: {
    scroll_to_end() {
      this.tail_timer = null
      if (this.follow_logs) {
        window.scrollTo(0, document.body.scrollHeight || document.documentElement.scrollHeight)
      }
    },

    watchNetwork() {
      this.channel.join()
      this.network_watch_ref = this.channel.on('packet_traffic', payload => {
        this.packets.push(payload)
      })
      this.watching_network = true
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
