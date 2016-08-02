_ = require 'lodash'
ArgumentParser = require('argparse').ArgumentParser
express = require 'express'
bodyParser = require 'body-parser'
paths = require '../common/paths'
router = express.Router()

cmdExecutor = {}

executCmd = (key, args, callback) ->
  executor = cmdExecutor[key]
  if !executor
    parser = new ArgumentParser()
    cmd = require("../subcmd/#{key}")
    conf = cmd.args
    if conf is null
      parser =
        parseArgs: (args) -> '': args
    else
      parser.addArgument(conf[i * 2], _.clone(conf[i * 2 + 1])) for i in [0...conf.length / 2]
    executor = cmdExecutor[key] = (args, callback) ->
      args = parser.parseArgs(args)
      console.log JSON.stringify(args, null, '  ')
      cmd.exec args, (err, ret) ->
        callback err, ret
      return
  executor args, callback
  return

router.use bodyParser.urlencoded(extended: true)
router.use bodyParser.json(limit: '1gb')

router.route '/:subcmd/:args'
.get (req, res) ->
  params = req.params
  executCmd "#{params.subcmd}", params.args.split(' '), (err, ret) ->
    if err
      res.json
        result: 1
        data: err.toString()
    else
      res.json
        result: 0
        data: ret
    return
  return

module.exports = router

