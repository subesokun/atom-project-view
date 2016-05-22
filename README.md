# Project View package

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

### Contributing

The project-view package tries to follow the [Atom contribution guidelines](https://atom.io/docs/latest/contributing).

Especially, the commits should follow the conventions defined in the *Git Commit Messages* section of the contribution guidelines.

[See all contributors](https://github.com/subesokun/atom-project-view/graphs/contributors)

### License

MIT
