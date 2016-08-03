pty = require 'pty.js'
paths = require '../paths'

lastConf = null
hugo = null

module.exports =
  install: (ms, socket) ->
    start = (conf) ->
      if hugo
        ms.emit 'hugo.console', 'hugo already started.\n'
      else
        lastConf = conf
        hugo = pty.spawn paths.bin('hugo'),
          '-p 1313 -t hugo-vaniship-theme -w server'.split(' '),
          name: 'hugo',
#          cwd: process.cwd(),
          env: process.env
        hugo.on 'exit', (code) ->
          ms.emit 'hugo.console', "hugo stopped(ExitCode:#{code}).\n"
          return
        hugo.on 'data', (data) ->
          ms.emit 'hugo.console', data
          console.log data
          return
      return

    stop = ->
      if hugo
        hugo.destroy()
        hugo = null
      else
        ms.emit 'hugo.console', "hugo already stopped.\n"
      return

    socket
    .on 'hugo.start', (conf) ->
      start(conf)
      return
    .on 'hugo.restart', (conf) ->
      stop()
      start(conf || lastConf)
      return
    .on 'hugo.stop', ->
      stop()
      return
    return
