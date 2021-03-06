{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
path = require 'path'
Project = require './project'

isRoot = (x) -> x && x.matches '[is=tree-view-directory].project-root'
rootNodes = (x) -> Array.from(x).filter(isRoot)

module.exports = ProjectView =
  config:
    displayPath:
      type: 'boolean'
      default: true
      description: 'Show the project path after project name in tree-view root.'
    regexMatch:
      type: 'string'
      default: ''
      description: 'Define a custom regex to match the parts in the project path that shall be replaced.'
    regexSubStr:
      type: 'string'
      default: '$&'
      description: 'If the regex matches, then substitute all matches with this string.'

  activate: ->
    @projectMap = {}
    # Events subscribed to in atom's system can be easily cleaned up with
    # a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.packages.onDidActivateInitialPackages =>
      @initProjectView()
    # Bind DOM mutation observer
    @observer = new MutationObserver((mutations) =>
      added = []
      added.push.apply added, rootNodes(m.addedNodes) for m in mutations
      if added.length > 0
        process.nextTick => @updateRoots()
    )
    # Workaround for the isse that "onDidActivateInitialPackages" never gets
    # fired if one or more packages are failing to initialize
    @activateInterval = setInterval (=>
        @initProjectView()
      ), 1000
    @initProjectView()
    @subscriptions.add(atom.commands.add('atom-workspace', {
      'project-view:toggle-path': ->
        atom.config.set('project-view.displayPath', !atom.config.get('project-view.displayPath'))
    }))

  initProjectView: ->
    if not @treeView?
      if atom.packages.getActivePackage('nuclide-tree-view')?
        treeViewPkg = atom.packages.getActivePackage('nuclide-tree-view')
      else if atom.packages.getActivePackage('tree-view')?
        treeViewPkg = atom.packages.getActivePackage('tree-view')

      @regexSubStr = atom.config.get('project-view.regexSubStr')
      @regexMatch = atom.config.get('project-view.regexMatch')
      @regex = new RegExp @regexMatch

      if treeViewPkg?.mainModule?.treeView?
        clearInterval(@activateInterval)
        @treeView = treeViewPkg.mainModule.treeView
        # Bind against events which are causing an update of the tree view
        @subscribeUpdateEvents()
        # Initally update the root names
        @updateRoots(@treeView.roots)

  deactivate: ->
    @observer?.disconnect()
    @subscriptions?.dispose()
    if @treeView?
      @clearRoots()
    @subscriptions = null
    @treeView = null
    @projectMap = null
    @regex = null
    @regexSubStr = ''
    @regexMatch = ''


  subscribeUpdateEvents: ->
    @subscriptions.add atom.project.onDidChangePaths =>
      @updateRoots()
    @subscriptions.add atom.config.onDidChange 'tree-view.hideVcsIgnoredFiles', =>
      @updateRoots()
    @subscriptions.add atom.config.onDidChange 'tree-view.hideIgnoredNames', =>
      @updateRoots()
    @subscriptions.add atom.config.onDidChange 'core.ignoredNames', =>
      @updateRoots() if atom.config.get('tree-view.hideIgnoredNames')
    @subscriptions.add atom.config.onDidChange 'tree-view.sortFoldersBeforeFiles', =>
      @updateRoots()
    @subscriptions.add atom.config.onDidChange 'project-view.displayPath', =>
      @updateRoots()
    @subscriptions.add atom.config.onDidChange 'project-view.regexMatch', =>
      @regexMatch = atom.config.get('project-view.regexMatch')
      @regex = new RegExp @regexMatch
      @updateRoots()
    @subscriptions.add atom.config.onDidChange 'project-view.regexSubStr', =>
      @regexSubStr = atom.config.get('project-view.regexSubStr')
      @updateRoots()
    @observer.observe(@treeView.list, { childList: true });

  updateRoots: ->
    if not @treeView?
      return
    roots = @treeView.roots
    for root in roots
      rootPath = root.getPath()
      project = @projectMap[rootPath]
      if not project?
        project = new Project(root)
        @projectMap[rootPath] = project
        # Bind for name changes and activate watcher
        project.onDidChange 'name', ({root, name}) =>
          @updateProjectRoot(root.getPath(), name)
        project.watch()
      if project.projectName
        # Project name has been already cached
        @updateProjectRoot(rootPath, project.projectName)
      else
        # Find the project name as it hasn't been cached yet
        project.findProjectName().then ({_, name}) =>
          @updateProjectRoot(rootPath, name)
        .catch (error) ->
          console.error(error, error.stack)
    # Clean up removed projects
    projectsToRemove = []
    for rootPath, project of @projectMap
      if not @findRootByPath(rootPath)?
        projectsToRemove.push(rootPath)
    for rootPath in projectsToRemove
      @projectMap[rootPath]?.destroy()
      delete @projectMap[rootPath]

  findRootByPath: (rootPath) ->
    for root in @treeView.roots
      if rootPath is root.getPath()
        return root

  clearRoots: ->
    roots = @treeView.roots
    for root in roots
      project = @projectMap[root.getPath()]
      if project?
        project.destroy()
      root.directoryName.textContent = root.directoryName.dataset.name
      root.directoryName.classList.remove('project-view')
      directoryPath = root.header.querySelector('.project-view-path')
      root.header.removeChild(directoryPath) if directoryPath?
      delete root.directoryPath
    @projectMap = {}

  updateProjectRoot: (rootPath, name) ->
    root = @findRootByPath(rootPath)
    if name?
      root.directoryName.textContent = name
      root.directoryName.classList.add('project-view')
    else
      root.directoryName.textContent = root.directoryName.dataset.name
      root.directoryName.classList.remove('project-view')
    if not root.directoryPath?
      root.directoryPath = document.createElement('span')
      root.header.appendChild(root.directoryPath)
    root.directoryPath.classList.add('name','project-view-path','status-ignored')
    if atom.config.get 'project-view.displayPath'
      root.directoryPath.textContent = '(' + @shortenRootPath(root.directory.path) + ')'
    else
      root.directoryPath.textContent = ''

  shortenRootPath: (rootPath) ->
    # Shorten root path if possible
    userHome = fs.getHomeDirectory()
    normRootPath = path.normalize(rootPath)

    if @regexMatch isnt ''
      replacedPath = normRootPath.replace(@regex, @regexSubStr)
      return replacedPath if replacedPath isnt normRootPath

    if normRootPath.indexOf(userHome) is 0
      # Use also tilde in case of Windows as synonym for the home folder
      return '~' + normRootPath.substring(userHome.length)
    else
      return normRootPath
