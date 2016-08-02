MessageServer = require './common/MessageServer'
pkgObj = require('../package.json')
ArgumentParser = require('argparse').ArgumentParser

mainParser = new ArgumentParser(
  version: pkgObj.version
  addHelp: true
  description: 'Hugo Helper'
  prog: 'hh'
)
mainCmdConf = [
  ['-a', '--address']
  help: '设置服务绑定地址'
  defaultValue: '127.0.0.1'
  ['-p', '--port']
  help: '设置服务绑定端口'
  defaultValue: 3000
]
mainParser.addArgument(mainCmdConf[i * 2], mainCmdConf[i * 2 + 1]) for i in [0...mainCmdConf.length / 2]
mainArgs = mainParser.parseArgs()

http = require 'http'
express = require('express')
paths = require './common/paths'

rest = express()
server = http.createServer(rest)

rest.use '/', require('./router/static')
rest.use '/cli', require('./router/cli')

MessageServer(server: server)

server.listen mainArgs.port, mainArgs.address, ->
  console.log "IDE 服务已启动(#{mainArgs.address}:#{mainArgs.port})..."
  return
