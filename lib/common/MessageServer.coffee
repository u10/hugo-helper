HugoRpc = require './HugoRpc'
socketIo = require 'socket.io'
rpc4js = require 'rpc4js'

module.exports = (options) ->
  ms = socketIo.listen(options.server)

  rpc4js
    .define 'hugo', (client) -> new HugoRpc(client)
    .listen ms

  ms.on 'connect', (socket) ->
    console.log "connected: #{socket.id}"
    socket
    .on 'disconnect', ->
      console.log "disconnected: #{socket.id}"
      return
    return
  ms
