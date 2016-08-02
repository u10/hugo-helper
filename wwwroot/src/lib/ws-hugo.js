export default function (ws) {
  return {
    addConsoleListener (cb) {
      ws.on('hugo.console', cb)
    },
    removeConsoleListener (cb) {
      ws.off('hugo.console', cb)
    },
    start (conf) {
      ws.emit('hugo.start', conf)
    },
    restart (conf) {
      ws.emit('hugo.restart', conf)
    },
    stop () {
      ws.emit('hugo.stop')
    }
  }
}
