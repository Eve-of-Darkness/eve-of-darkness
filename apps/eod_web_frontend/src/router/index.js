import Vue from 'vue'
import Router from 'vue-router'
import AdminDashboard from '@/components/AdminDashboard'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'AdminDashboard',
      component: AdminDashboard
    }
  ]
})
