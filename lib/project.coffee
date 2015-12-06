{Emitter} = require 'atom'
PathWatcher = require 'pathwatcher'
path = require 'path'
fs = require 'fs-plus'

class Project

  constructor: (@root) ->
    @emitter = new Emitter
    @projectName = null

  destory: ->
    @unwatch()
    @projectName = null
    @emitter?.dispose()
    @emitter = null

  unwatch: ->
    if @watchSubscription?
      @watchSubscription.close()
      @watchSubscription = null

  watch: ->
    if not @watchSubscription?
      try
        @watchSubscription = PathWatcher.watch @root.getPath(), (eventType, eventPath) =>
          switch eventType
            when 'change' then @findProjectName()

  onDidChange: (eventType, callback) ->
    @emitter.on eventType, callback

  findProjectName: ->
    rootPath = @root.getPath()
    return new Promise (resolve, reject) ->
      fs.readdir rootPath, (error, files) ->
        resolve(files)
    .then (files) =>
      if files.indexOf('package.json') isnt -1
        pkgFile = path.join rootPath, 'package.json'
        return @getPropertyFromPackageJson(pkgFile, 'name')
      else if files.indexOf('.bower.json') isnt -1
        pkgFile = path.join rootPath, '.bower.json'
        return @getPropertyFromPackageJson(pkgFile, 'name')
      else if files.indexOf('composer.json') isnt -1
        pkgFile = path.join rootPath, 'composer.json'
        return @getPropertyFromPackageJson(pkgFile, 'name')
    .then (name) =>
      result = {root: @root, name: name}
      @projectName = name
      @emitter.emit 'name', result
      return result

  getProjectName: ->
    return @projectName

  getPropertyFromPackageJson: (rootPath, property) ->
    return new Promise (resolve, reject) ->
      fs.readFile rootPath, 'utf8', (error, data) ->
        if error
          resolve(null)
        try
          pkgData = JSON.parse(data)
          if pkgData[property]
            resolve(pkgData[property])
          else
            resolve(null)
        catch error
          resolve(null)

module.exports = Project
