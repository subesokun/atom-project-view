{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
path = require 'path'
watch = require './watch'

module.exports = ProjectView =
  config:
    displayPath:
      type: 'boolean'
      default: true
      description: 'Show the project path after project name in tree-view root.'
  subscriptions: null
  treeView: null

  activate: ->
    # Events subscribed to in atom's system can be easily cleaned up with
    # a CompositeDisposable
    @subscriptions = new CompositeDisposable
    atom.packages.activatePackage('tree-view').then (treeViewPkg) =>
      @treeView = treeViewPkg.mainModule.createView()
      # Bind against events which are causing an update of the tree view
      @subscribeUpdateEvents()
      # Initally update the root names
      @updateRoots(@treeView.roots)
    .catch (error) ->
      console.error error, error.stack

  deactivate: ->
    @subscriptions.dispose()
    if @treeView?
      @clearRoots(@treeView.roots)
    @subscriptions = null
    @treeView = null

  subscribeUpdateEvents: ->
    @subscriptions.add atom.project.onDidChangePaths =>
      @updateRoots @treeView.roots
    @subscriptions.add atom.config.onDidChange 'tree-view.hideVcsIgnoredFiles', =>
      @updateRoots @treeView.roots
    @subscriptions.add atom.config.onDidChange 'tree-view.hideIgnoredNames', =>
      @updateRoots @treeView.roots
    @subscriptions.add atom.config.onDidChange 'core.ignoredNames', =>
      @updateRoots(@treeView.roots) if atom.config.get('tree-view.hideIgnoredNames')
    @subscriptions.add atom.config.onDidChange 'tree-view.sortFoldersBeforeFiles', =>
      @updateRoots @treeView.roots
    @subscriptions.add atom.config.onDidChange 'project-view.displayPath', =>
      @updateRoots @treeView.roots

  updateRoots: (roots) ->
    for root in roots
      @getProjectName(root).then ({root, name}) =>
        if name
          root.directoryName.textContent = name
          root.directoryName.classList.add('project-view')
        if !root.directoryPath
          root.directoryPath = document.createElement('span')
          root.header.appendChild(root.directoryPath)
        root.directoryPath.classList.add('name','project-view-path','status-ignored')
        if atom.config.get 'project-view.displayPath'
          root.directoryPath.textContent = '(' + @shortenRootPath(root.directory.path) + ')'
        else
          root.directoryPath.textContent = ''
      .catch (error) ->
        console.error error, error.stack

  clearRoots: (roots) ->
    for root in roots
      root.directoryName.textContent = root.directoryName.dataset.name
      root.directoryName.classList.remove('project-view')
      directoryPath = root.header.querySelector('.project-view-path')
      root.header.removeChild(directoryPath)

  getProjectName: (root) ->
    return new Promise (resolve, reject) ->
      fs.readdir root.getPath(), (error, files) ->
        resolve(files)
    .then (files) =>
      if files.indexOf('package.json') isnt -1
        pkgFile = path.join root.getPath(), 'package.json'
        return @getPropertyFromPackageJson(pkgFile, 'name').then (value) ->
          {root: root, name: value}
      else if files.indexOf('.bower.json') isnt -1
        pkgFile = path.join root.getPath(), '.bower.json'
        return @getPropertyFromPackageJson(pkgFile, 'name').then (value) ->
          {root: root, name: value}
      else if files.indexOf('composer.json') isnt -1
        pkgFile = path.join root.getPath(), 'composer.json'
        return @getPropertyFromPackageJson(pkgFile, 'name').then (value) ->
          {root: root, name: value}
      else
        {root: root, name: null}

  updateProjectName: (path) ->
    @updateRoots(@treeView.roots)

  getPropertyFromPackageJson: (path, property) ->
    return new Promise (resolve, reject) ->
      fs.readFile path, 'utf8', (error, data) ->
        if error
          resolve(null)
        try
          pkgData = JSON.parse(data)
          if pkgData[property]
            scope = ProjectView
            w = new watch.WatchFile(path, 1500, ((self) -> scope.updateProjectName path ), scope)
            w.start()
            resolve(pkgData[property])
          else
            resolve(null)
        catch error
          resolve(null)

  shortenRootPath: (rootPath) ->
    # Shorten root path if possible
    userHome = fs.getHomeDirectory()
    normRootPath = path.normalize(rootPath)
    if normRootPath.indexOf(userHome) is 0
      # Use also tilde in case of Windows as synonym for the home folder
      '~' + normRootPath.substring(userHome.length)
    else
      rootPath
