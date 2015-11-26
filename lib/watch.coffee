fs = require 'fs'

class WatchFile

  constructor: (@path, @interval, @observer, @scope) ->
    @dead = false
    @mtime = false

  _target: (me) ->
    me.run()
    if not @dead
      setTimeout (-> me._target me), me.interval

  start: ->
    me = @
    setTimeout (-> me._target me), 1

  run: ->
    stat = fs.statSync(@path)

    if not @mtime
      @mtime = stat.mtime
    else if @mtime.getTime() != stat.mtime.getTime()
      @mtime = stat.mtime
      @observer @scope or {}


module.exports =
  WatchFile: WatchFile
