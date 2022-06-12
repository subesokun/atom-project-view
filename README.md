# Project View package

> This project is no longer maintained as Atom and all repositories under Atom will be archived on December 15, 2022. Learn more in the [official announcement](https://github.blog/2022-06-08-sunsetting-atom/). Thank you for your interest in this project and your support!

[![Version](https://img.shields.io/apm/v/project-view.svg)](https://atom.io/packages/project-view)
[![Downloads](https://img.shields.io/apm/dm/project-view.svg)](https://atom.io/packages/project-view)

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
