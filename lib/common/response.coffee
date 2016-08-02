mkMsg = (defaultMsg, customMsg, append) -> if append is false then customMsg || defaultMsg else "#{defaultMsg}[#{customMsg}]"

module.exports =
  Success:
    Info: (@msg) ->
      @result = 0
      return
    Data: (@data) ->
      @result = 0
      return
    Value: (@value) ->
      @result = 0
      return
  Error:
    UnknownError: (msg, append) ->
      @msg = mkMsg('未知错误!', msg, append)
      @result = 9500
      return
