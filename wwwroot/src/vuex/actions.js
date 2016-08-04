import * as types from './mutation-types'

export const setExplorerData = ({dispatch}, data) => {
  dispatch(types.SET_EXPLORER_DATA, data)
}
