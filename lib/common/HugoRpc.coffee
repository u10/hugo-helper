pty = require 'pty.js'
paths = require '../paths'
fse = require 'fs-extra'

hugo = null

module.exports = class
  constructor: (@client) ->
    return
  create: (rpc, conf, callback) ->
    client = @client
    task = pty.spawn paths.bin('hugo'),
      "new site #{conf.path}".split(' '),
      name: 'hugo',
      env: process.env
    task.on 'exit', (code) ->
      fse.copySync(paths.data('themes', 'hyde'), paths.join(conf.path, 'themes', 'hyde'))
      fse.outputFileSync(paths.join(conf.path, 'config.toml'), 'theme = "hyde"', flag: 'a')
      if code
        client.log "create failed(ExitCode:#{code}).\n"
        callback 'error'
      else
        client.log "create success.\n"
        do callback
      return
    task.on 'data', (data) ->
      client.log data
      console.log data
      return
    return
  start: (rpc, conf) ->
    client = @client
    if hugo
      client.log 'hugo already started.\n'
    else
      conf = @lastConf = conf || @lastConf
      unless conf
        client.log 'can not start hugo without config.\n'
        return
      hugo = pty.spawn paths.bin('hugo'),
        '--buildDrafts --watch server'.split(' '),
        name: 'hugo',
        cwd: conf.path,
        env: process.env
      hugo.on 'exit', (code) ->
        client.log "hugo exit(code:#{code}).\n"
        return
      hugo.on 'data', (data) ->
        client.log data
        console.log data
        return
    return
  stop: ->
    client = @client
    if hugo
      hugo.destroy()
      hugo = null
      client.log "hugo stopped.\n"
    else
      client.log "hugo already stopped.\n"
    return
  restart: (rpc, conf)->
    @stop()
    @start(conf)
