import _ from 'lodash'
import $ from 'jquery'
import {Base64} from 'js-base64'
function deal (ret, done, error) {
  if (ret.result) {
    if (_.isFunction(error)) {
      error()
    }
  } else {
    done(ret.data)
  }
}
export default {
  ls (path, done, error) {
    $.ajax({
      url: '/cli/dir/' + encodeURIComponent(`list -p ${path} -d 32`)
    })
      .done(function (data) {
        deal(data, done, error)
      })
      .error(error)
  },
  mkdir (path, done, error) {
    $.ajax({
      url: '/cli/dir/' + encodeURIComponent(`add -p ${path}`)
    })
      .done(function (data) {
        deal(data, done, error)
      })
      .error(error)
  },
  cat (path, done, error) {
    $.ajax({
      url: '/cli/file/' + encodeURIComponent(`get -p ${path}`)
    })
      .done(function (data) {
        deal(data, done, error)
      })
      .error(error)
  },
  save (path, data, done, error) {
    $.ajax({
      url: '/cli/file/' + encodeURIComponent(`set -p ${path} -d ${Base64.encode(data)}`)
    })
      .done(function (data) {
        deal(data, done, error)
      })
      .error(error)
  },
  mv (oldPath, newPath, done, error) {
    $.ajax({
      url: '/cli/file/' + encodeURIComponent(`rename -p ${oldPath} -d ${newPath}`)
    })
      .done(function (data) {
        deal(data, done, error)
      })
      .error(error)
  },
  rm (path, done, error) {
    $.ajax({
      url: '/cli/file/' + encodeURIComponent(`del -p ${path}`)
    })
      .done(function (data) {
        deal(data, done, error)
      })
      .error(error)
  }
}
