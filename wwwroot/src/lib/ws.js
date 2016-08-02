import io from 'socket.io-client'
import wsTerm from './ws-term'
import wsHugo from './ws-hugo'

const ws = io(`ws://${window.location.host}`, {
  autoConnect: false
})

ws.connect()

export const hugo = wsHugo(ws)
export const term = wsTerm(ws)
