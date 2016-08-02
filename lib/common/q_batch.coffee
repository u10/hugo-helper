_ = require 'lodash'
Q = require 'q'
fork = require('child_process').fork
spawn = require('child_process').spawn

run = do ->
  deferred = Q.defer()
  deferred.resolve()
  deferred.promise

Q.batch = (promises, errcb) ->
  bus = run
  for promise in promises
    switch
      when _.isObject(promise)
        do ->
          conf = _.defaults promise,
            desc: 'no desc task ...'
            type: 'fun'
          conf = _.defaults promise,
            msg: "#{conf.desc} ok."
            err: "#{conf.desc} failed."
          promise = Q.batch[conf.type](conf)
    bus = bus.then(promise)
  bus.catch errcb
  return

Q.batch.promise = (conf) ->
  ->
    console.log conf.desc
    conf.promise()
    .then ->
      console.log conf.msg || "#{conf.desc} ok."
      return
    .catch ->
      console.log conf.msg || "#{conf.desc} failed."
      return

Q.batch.fun = (conf) ->
  ->
    console.log conf.desc unless conf.desc is null
    deferred = Q.defer()
    err = conf.fun()
    if _.isUndefined(err)
      console.log conf.msg || "#{conf.desc} ok." unless conf.desc is null
      deferred.resolve()
    else
      console.log conf.err || "#{conf.desc} failed." unless conf.desc is null
      deferred.reject(conf.err)
    deferred.promise

Q.batch.fork = (conf) ->
  ->
    console.log conf.desc
    deferred = Q.defer()
    fork(conf.file, unescape(conf.args.split(' ')).split(','), conf.options)
    .on 'exit', (code) ->
      if code is 0
        console.log conf.msg || "#{conf.desc} ok."
        deferred.resolve()
      else
        conf.err || "#{conf.desc} failed."
        deferred.reject(conf.err)
      return
    deferred.promise

Q.batch.spawn = (conf) ->
  ->
    console.log conf.desc
    deferred = Q.defer()
    spawn(conf.command, conf.args.split(' '), conf.options)
    .on 'exit', (code) ->
      if code is 0
        console.log conf.msg || "#{conf.desc} ok."
        deferred.resolve()
      else
        conf.err || "#{conf.desc} failed."
        deferred.reject(conf.err)
      return
    deferred.promise

module.exports = Q
