# v0.5.0 (2015-01-31)

## Features
- Add command and keymap binding for toggling the project path (thanks to @rodrigopmatias, [#12](https://github.com/subesokun/atom-project-view/issues/12))


# v0.4.1 (2015-12-13)

## :bug: Bug Fixes
- Remove `pathwatcher` due to installation issues on Windows ([3550b1e](https://github.com/subesokun/atom-project-view/commit/3550b1edbe62c70459208ebf52b0f4f934ab89c4))


# v0.4.0 (2015-12-12)

## Features
- Add support for live update of the project name (thanks for support to @rodrigopmatias, [#1](https://github.com/subesokun/atom-project-view/issues/1))
- Rework package activation to not forcefully load the tree-view ([#8](https://github.com/subesokun/atom-project-view/issues/8))

## :bug: Bug Fixes
- Fix issue with empty root directories ([#11](https://github.com/subesokun/atom-project-view/issues/11))


# v0.3.0 (2015-11-24)

## Features
- Added setting to show or not the project path (thanks to @rodrigopmatias, [#9](https://github.com/subesokun/atom-project-view/issues/9))


# v0.2.0 (2015-11-08)

## Features
- Add support for Composer (thanks to @JasonMiesionczek, [#7](https://github.com/subesokun/atom-project-view/issues/7))


# v0.1.2 (2015-04-13)

## :bug: Bug Fixes
- Gracefully deactivate package ([#2](https://github.com/subesokun/atom-project-view/issues/2))
- Use `fs-plus` to get the home directory

## :racehorse: Performances
- Remove core-js dependency for faster startup


# v0.1.1 (2015-04-07)

## :bug: Bug Fixes
- Ensure that the treeView is created before referencing it


# v0.1.0 (2015-04-06)
:sparkles: First release of `project-view` with support for npm and bower package files
