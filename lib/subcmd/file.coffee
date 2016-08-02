path = require 'path'
paths = require '../paths'

module.exports =
  conf:
    description: '文件操作'
  args: [
    ['cmd']
    help: '指定操作命令'
    choices: ['get', 'set', 'add', 'create', 'del', 'delete', 'rename']
    ['-p', '--path']
    help: '指定文件路径'
    ['-d', '--data']
    help: '指定文件内容'
  ]
  exec: (args, callback) ->
    Q = require('../common/q_batch')
    cmd = args.cmd
    args.path = paths.normalize(args.path)

    Q.batch [
      {
        desc: "#{cmd} file ..."
        fun: ->
          fse = require 'fs-extra'
          ret = switch cmd
            when 'set'
              data = new Buffer(args.data, 'base64') + ''
              fse.writeFileSync(args.path, data)
              true
            when 'get'
              fse.readFileSync(args.path).toString()
            when 'rename'
              fse.renameSync(args.path, args.data)
            when 'add', 'create'
              fse.writeFileSync(args.path, '')
              true
            when 'del', 'delete'
              fse.removeSync(args.path)
              true
            else
              throw new Error()
          callback? null, ret
          console.log ret
          return
      }
    ], (err) ->
      callback? err
      console.log "#{cmd} file failed: #{err}"
      return

    return
