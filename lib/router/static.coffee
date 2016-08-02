express = require 'express'
favicon = require('serve-favicon')
paths = require '../paths'
router = express.Router()
router.use favicon(paths.wwwroot('static', 'img', 'favicon.ico'))
router.use express.static(paths.wwwroot())
module.exports = router

