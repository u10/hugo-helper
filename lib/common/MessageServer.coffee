_ = require 'lodash'
hugo = require './ws-hugo'
socketIo = require 'socket.io'

module.exports = (options) ->
  ms = socketIo.listen(options.server)
  ms.on 'connect', (socket) ->
    console.log 'connected.' + socket.id

    hugo.install ms, socket

    socket
    .on 'disconnect', ->
      console.log 'disconnected.'
      return
    return
  ms
