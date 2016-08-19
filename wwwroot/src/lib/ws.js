import io from 'socket.io-client'
import rpc4js from 'rpc4js'

const ws = io(`ws://${window.location.host}`, {
  autoConnect: false
})

export const rpc = rpc4js.bind(ws)

ws.connect()
