import * as types from './mutation-types'

export const setExplorerData = ({dispatch}, data) => {
  dispatch(types.SET_EXPLORER_DATA, data)
}

export const openFile = ({dispatch}, data) => {
  dispatch(types.OPEN_FILE, data)
}

export const closeFile = ({dispatch}, data) => {
  dispatch(types.CLOSE_FILE, data)
}

export const setSelectedEditor = ({dispatch}, data) => {
  dispatch(types.SET_SELECTED_EDITOR, data)
}
