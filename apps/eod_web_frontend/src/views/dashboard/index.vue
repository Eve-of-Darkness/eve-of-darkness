<template>
  <div class="dashboard-container">
    <overview-panel />
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import OverviewPanel from '../../components/OverviewPanel'

export default {
  name: 'Dashboard',
  components: {
    OverviewPanel
  },
  computed: {
    ...mapGetters([
      'name'
    ])
  }
}
</script>

<style lang="scss" scoped>
.dashboard {
  &-container {
    margin: 30px;
  }
  &-text {
    font-size: 30px;
    line-height: 46px;
  }
}
</style>
