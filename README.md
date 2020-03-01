# Project View package

[![Version](https://img.shields.io/apm/v/project-view.svg?style=flat-square)](https://atom.io/packages/project-view)
[![Downloads](https://img.shields.io/apm/dm/project-view.svg?style=flat-square)](https://atom.io/packages/project-view)
[![Status Linux & OSX](https://img.shields.io/travis/subesokun/atom-project-view.svg?style=flat-square&label=Linux%20%26%20OSX)](https://travis-ci.org/subesokun/atom-project-view)
[![Status Windows](https://img.shields.io/appveyor/ci/subesokun/atom-project-view.svg?style=flat-square&label=Windows)](https://ci.appveyor.com/project/subesokun/atom-project-view)
[![Dependency Status](https://img.shields.io/david/subesokun/atom-project-view.svg?style=flat-square)](https://david-dm.org/subesokun/atom-project-view)

Shows project details in the Atom tree-view.

### Screenshots

![project-view Screenshot](https://github.com/subesokun/atom-project-view/blob/master/screenshot.png?raw=true)

![project-view Screenshot Settings](https://github.com/subesokun/atom-project-view/blob/master/screenshot-settings.png?raw=true)

### Installation

```
apm install project-view
```

### Features

* Replaces the Atom tree-view root folder name by the corresponding project name if available
* Shows the project folder path next to the project name
* Supported files to retrieve the project name (ordered by priority):
 * `package.json` (npm-like)
 * `.bower.json` (bower)
 * `composer.json` (Composer)

#### Customize the project path via regex

Via a regex you can easily shorten the project path or show other additional information that are useful for you. Furthermore you could also obfuscate the project path for more privacy.

![project-view Screenshot Project Path Regex](https://github.com/subesokun/atom-project-view/blob/master/screenshot-path-regex.png?raw=true)

### License

MIT
