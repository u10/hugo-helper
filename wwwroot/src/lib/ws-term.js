export default function (ws) {
  let cbs = {}
  return {
    open (conf, cb) {
      cbs[conf.id] = cb
      ws.on('term.data', cb)
      ws.emit('term.open', conf)
    },
    exec (cmd) {
      ws.emit('term.exec', cmd)
    },
    break () {
      ws.emit('term.break')
    },
    close (id) {
      ws.emit('term.close', id)
      const cb = cbs[id]
      if (cb) {
        ws.off('term.data', cb)
        delete cbs[id]
      }
    }
  }
}
