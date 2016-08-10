path = require 'path'
fse = require 'fs-extra'
paths = require '../paths'

module.exports =
  conf:
    description: '文件夹操作'
  args: [
    ['cmd']
    help: '指定操作命令'
    choices: ['list', 'add', 'create', 'del', 'delete']
    ['-p', '--path']
    help: '指定文件夹路径'
    defaultValue: '.'
    ['-d', '--deep']
    help: '指定文件夹路径'
    type: 'int'
    defaultValue: Infinity
  ]
  exec: (args, callback) ->
    Q = require('../common/q_batch')
    cmd = args.cmd
    args.path = paths.normalize(args.path)

    getFileTree = (dir, maxDeep = 0, base, node = [], deep = 0) ->
      filePath = if base then path.join(base, dir) else dir
      stats = fse.statSync(filePath)
      deep++
      if stats.isDirectory()
        node.push obj =
          text: dir
          type: '.'
          children: []
        if deep - 2 < maxDeep
          for file in fse.readdirSync(filePath)
            getFileTree file, maxDeep, filePath, obj.children, deep
      else
        node.push
          text: dir
          type: path.extname(dir)
      deep--
      return node

    Q.batch [
      {
        desc: "#{cmd} dir ..."
        fun: ->
          ret = switch cmd
            when 'list'
              getFileTree(args.path, args.deep)
            when 'add', 'create'
              fse.mkdirsSync(args.path)
              true
            when 'del', 'delete'
              fse.removeSync(args.path)
              true
            else
              throw new Error()
          callback? null, ret
          console.log JSON.stringify(ret, null, '  ')
          return
      }
    ], (err) ->
      callback? err
      console.log "#{cmd} dir failed: #{err}"
      return

    return
