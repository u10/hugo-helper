import './lib/polyfills'
import Vue from 'vue'
import App from './App'
import './i18n'
import Router from 'vue-router'

Vue.use(Router)
const router = new Router()
router.start(App, 'app')

let lang = /(?:\?|&)lang=(\w+)(?:$|&)/.exec(window.location.search)
if (lang) {
  lang = lang[1]
} else {
  lang = 'chs'
}

Vue.config.lang = lang
