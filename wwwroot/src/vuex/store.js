import _ from 'lodash'
import Vue from 'vue'
import Vuex from 'vuex'
import { SET_EXPLORER_DATA, OPEN_FILE, CLOSE_FILE, SET_SELECTED_EDITOR } from './mutation-types'

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
  },
  [OPEN_FILE] (state, data) {
    const editor = state.window.editor
    let index = _.findIndex(editor.data, function (o) { return o.path === data.path })
    if (index === -1) {
      editor.data.push(data)
      index = editor.data.length - 1
    }
    editor.selected.$set(0, index)
  },
  [CLOSE_FILE] (state, index) {
    const editor = state.window.editor
    editor.data.splice(index, 1)
    if (editor.selected[0] > editor.data.length - 1) {
      editor.selected.$set(0, Math.max(0, editor.data.length - 1))
    }
  },
  [SET_SELECTED_EDITOR] (state, index) {
    state.window.editor.selected.$set(0, index)
  }
}

export default new Vuex.Store({
  state,
  mutations
})
