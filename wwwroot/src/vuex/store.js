import Vue from 'vue'
import Vuex from 'vuex'
import { SET_EXPLORER_DATA } from './mutation-types'

Vue.use(Vuex)

const state = {
  status: {
    visible: true,
    data: []
  },
  window: {
    explorer: {
      visible: true,
      data: []
    },
    editor: {
      visible: true,
      selected: [0],
      data: []
    },
    ret: {
      title: 'test',
      path: 'fake/path',
      content: 'Hello World!'
    }
  }
}

const mutations = {
  [SET_EXPLORER_DATA] (state, data) {
    state.window.explorer.data = data
  }
}

export default new Vuex.Store({
  state,
  mutations
})
