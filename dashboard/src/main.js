import Vue from 'vue'
import App from './App.vue'
import router from './router'

Vue.config.productionTip = false

export const web3 = new window.Web3('http://127.0.0.1:7545');

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
