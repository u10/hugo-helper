// see http://vuejs-templates.github.io/webpack for documentation.
var path = require('path')

module.exports = {
  build: {
    env: require('./prod.env'),
    index: path.resolve(__dirname, '../dist/wwwroot/index.html'),
    assetsRoot: path.resolve(__dirname, '../dist/wwwroot'),
    assetsSubDirectory: 'static',
    assetsPublicPath: '/',
    productionSourceMap: false
  },
  dev: {
    env: require('./dev.env'),
    port: 8080,
    proxyTable: {
      '/cli':'http://localhost:3000',
      '/static':'http://localhost:3000',
      '/socket.io':'ws://localhost:3000'
    }
  }
}
