{Emitter} = require 'atom'
path = require 'path'
fs = require 'fs-plus'

class Project

  constructor: (@root) ->
    @emitter = new Emitter
    @projectName = null
    @trackedFile = null

  destory: ->
    @unwatch()
    @projectName = null
    @trackedFile = null
    @emitter?.dispose()
    @emitter = null

  unwatch: ->
    if @watchSubscription?
      @watchSubscription.close()
      @watchSubscription = null

  watch: ->
    if not @watchSubscription?
      try
        @watchSubscription = fs.watch @root.getPath(), (event, filename) =>
          if event is 'change'
            @findProjectName() if filename is @trackedFile
          else
            @findProjectName()

  onDidChange: (eventType, callback) ->
    @emitter.on eventType, callback

  findProjectName: ->
    rootPath = @root.getPath()
    return new Promise (resolve, reject) ->
      fs.readdir rootPath, (error, files) ->
        resolve(files)
    .then (files) =>
      return if not files?
      if files.indexOf('package.json') isnt -1
        pkgFile = path.join rootPath, 'package.json'
        @trackedFile = 'package.json'
        return @getPropertyFromPackageJson(pkgFile, 'name')
      else if files.indexOf('.bower.json') isnt -1
        pkgFile = path.join rootPath, '.bower.json'
        @trackedFile = '.bower.json'
        return @getPropertyFromPackageJson(pkgFile, 'name')
      else if files.indexOf('composer.json') isnt -1
        pkgFile = path.join rootPath, 'composer.json'
        @trackedFile = 'composer.json'
        return @getPropertyFromPackageJson(pkgFile, 'name')
      else
        @trackedFile = null
        return
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
