_ = require 'lodash'
pty = require 'pty.js'

module.exports =
  install: (ms, socket) ->
    socket.terms = {}
    socket
    .on 'term.open', (conf) ->
      socket.join(conf.id)
      cmd = conf.cmd.split(' ')
      term = socket.terms[conf.id] = pty.spawn cmd[0], cmd[1..], _.defaults(conf, {
        cwd: process.cwd(),
        env: process.env
      })
      term.on 'data', (data) ->
        ms.to(conf.id).emit 'term.console', data
        console.log data
        return
      return
    .on 'term.close', (id) ->
      term = socket.terms[id]
      if term
        term.destroy()
        delete socket.terms[id]
      return
    return
