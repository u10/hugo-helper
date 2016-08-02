import 'pure-css'

import './lib/polyfills'
import Vue from 'vue'
import App from './App'
import './i18n'
import Router from 'vue-router'
import Editor from 'components/Editor'
// import Sortable from 'vue-sortable'
// Vue.use(Sortable)
// import MintUI from 'mint-ui'
// Vue.use(MintUI)
Vue.use(Router)
const router = new Router({abstract: false})
router.map({
  '/': {
    component: {
      template: '<p>Default</p>'
    }
  },
  '/editor': {
    name: 'editor',
    component: Editor
  }
})

router.beforeEach(function (transition) {
  transition.next()
})

router.start(App, 'app')

let lang = /(?:\?|&)lang=(\w+)(?:$|&)/.exec(window.location.search)
if (lang) {
  lang = lang[1]
} else {
  lang = 'chs'
}

Vue.config.lang = lang
